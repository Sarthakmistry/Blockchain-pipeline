from pyspark.sql import SparkSession
from pyspark.sql.functions import col, udf
from pyspark.ml.feature import VectorAssembler, StandardScaler
from pyspark.ml.clustering import KMeans
from pyspark.ml.linalg import Vectors, DenseVector
import math
from pyspark.ml import Pipeline
import os
from google.cloud import bigquery
import pandas as pd

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "bitcoindata-457720-f464ff7656ea.json"

client = bigquery.Client()

query = """
SELECT
  t.hash,
  t.size,
  ARRAY_LENGTH(t.inputs) AS vin_sz,
  ARRAY_LENGTH(t.outputs) AS vout_sz,
  (SELECT SUM(i.value) FROM UNNEST(t.inputs) i) AS input_value,
  (SELECT SUM(o.value) FROM UNNEST(t.outputs) o) AS output_value,
  (SELECT SUM(i.value) FROM UNNEST(t.inputs) i) -
  (SELECT SUM(o.value) FROM UNNEST(t.outputs) o) AS fee,
  t.block_timestamp
FROM `bigquery-public-data.crypto_bitcoin.transactions` t TABLESAMPLE SYSTEM (1 PERCENT)
WHERE t.block_timestamp IS NOT NULL
ORDER BY t.block_timestamp DESC
LIMIT 100000000
"""

df = client.query(query).to_dataframe()

spark = SparkSession.builder \
    .appName("Bitcoin Anomaly Detection") \
    .getOrCreate()

df = spark.read.csv("bitcoin_transactions.csv",
                     header=True,
                     inferSchema=True)

feature_cols = ["size", "vin_sz", "vout_sz", "input_value", "output_value", "fee"]

assembler = VectorAssembler(inputCols=feature_cols,
                            outputCol="features_vec",
                            handleInvalid="skip")

# Scaling features
scaler = StandardScaler(inputCol="features_vec",
                        outputCol="scaled_features",
                        withStd=True, 
                        withMean=True)

# KMeans clustering
kmeans = KMeans(featuresCol="scaled_features",
                 predictionCol="cluster",
                 k=5,
                 seed=42)

# Building pipeline
pipeline = Pipeline(stages=[assembler, scaler, kmeans])

model = pipeline.fit(df)
result = model.transform(df)

# Getting cluster centers
centers = model.stages[-1]\
               .clusterCenters()

# UDF to compute distance from nearest cluster center
def euclidean_distance(vec, center):
    return float(math.sqrt(sum((x - y) ** 2 for x, y in zip(vec, center))))

def get_distance(vec, cluster):
    return euclidean_distance(vec, centers[cluster])

distance_udf = udf(get_distance)

# Adding anomaly score
scored = result.withColumn("anomaly_score", distance_udf(col("scaled_features"), col("cluster")))

# Show top anomalies (highest distance)
scored.select("hash", "fee", "cluster", "anomaly_score") \
      .orderBy(col("anomaly_score").desc()) \
      .show(truncate=False)

model.write()\
     .overwrite()\
     .save("models/bitcoin_anomaly_kmeans")