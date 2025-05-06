from pyspark.sql import SparkSession
from pyspark.sql.functions import col, expr, from_json, udf
from pyspark.sql.types import *
from pyspark.ml import PipelineModel
import math


spark = SparkSession.builder \
    .appName("BTC Anomaly Detection Streaming") \
    .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer") \
    .getOrCreate()

# Loading trained SparkML model
model = PipelineModel.load("hdfs:///models/btc_anomaly_model")
print("Model loaded successfully.")


# Kafka source
kafka_df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "10.1.174.61:9092") \
    .option("subscribe", "blockchain.txs") \
    .load()

tx_schema = StructType([
    StructField("lock_time", LongType()),
    StructField("ver", IntegerType()),
    StructField("size", IntegerType()),
    StructField("vin_sz", IntegerType()),
    StructField("vout_sz", IntegerType()),
    StructField("time", LongType()),
    StructField("hash", StringType()),
    StructField("relayed_by", StringType()),
    StructField("inputs", ArrayType(StructType([
        StructField("sequence", LongType()),
        StructField("prev_out", StructType([
            StructField("value", LongType())
        ]))
    ]))),
    StructField("out", ArrayType(StructType([
        StructField("value", LongType())
    ])))
])

# Parsing stream
df = kafka_df.selectExpr("CAST(value AS STRING) as json") \
    .withColumn("data", from_json(col("json"), tx_schema)) \
    .select("data.*")
print("Kafka stream schema parsed...")

# Feature engineering
features_df = df \
    .withColumn("input_value", expr("aggregate(inputs, 0L, (acc, x) -> acc + x.prev_out.value)")) \
    .withColumn("output_value", expr("aggregate(out, 0L, (acc, x) -> acc + x.value)")) \
    .withColumn("fee", col("input_value") - col("output_value")) \
    .select("hash", "size", "vin_sz", "vout_sz", "input_value", "output_value", "fee")

print("Applying ML model...")
scored_df = model.transform(features_df)

# Adding anomaly score (Euclidean distance from cluster center)
centers = model.stages[-1].clusterCenters()

def compute_score(vec, cluster):
    c = centers[cluster]
    return float(math.sqrt(sum((x - y) ** 2 for x, y in zip(vec, c))))

score_udf = udf(compute_score)
scored_with_anomaly = scored_df.withColumn("anomaly_score", score_udf(col("scaled_features"), col("cluster")))

print("Writing to Hudi...")
scored_with_anomaly_clean = scored_with_anomaly.select(
    "hash", "size", "vin_sz", "vout_sz",
    "input_value", "output_value", "fee",
    "cluster", "anomaly_score"
)
scored_with_anomaly_clean.printSchema()
scored_with_anomaly_clean.writeStream \
    .format("hudi") \
    .option("hoodie.table.name", "block_tx_stream") \
    .option("hoodie.table.type", "COPY_ON_WRITE") \
    .option("hoodie.metadata.enable", "false") \
    .option("checkpointLocation", "hdfs://10.1.174.61:9000/checkpoints/block_tx_stream") \
    .option("path", "hdfs://10.1.174.61:9000/user/stream/block_tx_stream/") \
    .option("hoodie.datasource.write.recordkey.field", "hash") \
    .option("hoodie.datasource.write.partitionpath.field", "cluster") \
    .option("hoodie.datasource.write.table.name", "block_tx_stream") \
    .option("hoodie.datasource.hive_sync.enable", "true") \
    .option("hoodie.datasource.hive_sync.database", "default") \
    .option("hoodie.datasource.hive_sync.table", "block_tx_stream") \
    .option("hoodie.datasource.hive_sync.partition_fields", "cluster") \
    .option("hoodie.datasource.hive_sync.mode", "hms") \
    .option("hoodie.datasource.hive_sync.metastore.uris", "thrift://10.1.174.61:9083") \
    .outputMode("append") \
    .start()

# Writing high-anomaly transactions to a separate Hudi table
anomalies = scored_with_anomaly_clean.filter(col("anomaly_score") > 50)

anomalies.writeStream \
    .format("hudi") \
    .option("hoodie.table.name", "tx_anomalies") \
    .option("hoodie.table.type", "COPY_ON_WRITE") \
    .option("hoodie.metadata.enable", "false") \
    .option("checkpointLocation", "hdfs://10.1.174.61:9000/checkpoints/tx_anomalies") \
    .option("path", "hdfs://10.1.174.61:9000/user/stream/tx_anomalies/") \
    .option("hoodie.datasource.write.recordkey.field", "hash") \
    .option("hoodie.datasource.write.partitionpath.field", "cluster") \
    .option("hoodie.datasource.write.table.name", "tx_anomalies") \
    .option("hoodie.datasource.hive_sync.enable", "true") \
    .option("hoodie.datasource.hive_sync.database", "default") \
    .option("hoodie.datasource.hive_sync.table", "tx_anomalies") \
    .option("hoodie.datasource.hive_sync.partition_fields", "cluster") \
    .option("hoodie.datasource.hive_sync.mode", "hms") \
    .option("hoodie.datasource.hive_sync.metastore.uris", "thrift://10.1.174.61:9083") \
    .outputMode("append") \
    .start()

spark.streams.awaitAnyTermination()