#################################### Starting Services ######################################

# start hdfs
$HADOOP_HOME/sbin/start-dfs.sh
#stop hdfs
$HADOOP_HOME/sbin/stop-dfs.sh

#Command to start zookeeper:
$KAFKA_HOME/bin/zookeeper-server-start.sh   $KAFKA_HOME/config/zookeeper.properties
#Command to stop zookeeper:
$KAFKA_HOME/bin/zookeeper-server-stop.sh   $KAFKA_HOME/config/zookeeper.properties

#Command to start kafka:
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
#Command to stop kafka:
$KAFKA_HOME/bin/kafka-server-stop.sh $KAFKA_HOME/config/server.properties

#Command to start Spark
$SPARK_HOME/sbin/start-all.sh
#Command to stop Spark
$SPARK_HOME/sbin/stop-all.sh

#Start trino
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ~/trino/bin/launcher start
#Stop Trino
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ~/trino/bin/launcher stop

###########################################################################################

#Command to access trino CLI
~/trino/bin/trino-cli \
  --server http://10.1.174.61:8090 \
  --catalog hudi \
  --schema default

#Command to create kafka topic
$KAFKA_HOME/bin/kafka-topics.sh --create \
  --bootstrap-server master:9092 \
  --replication-factor 3 \
  --partitions 3 \
  --topic blockchain.txs

#Command to start producer on master node
python bit_producer.py

#Command to start spark application (Consumer) on master node
~/spark/bin/spark-submit --master yarn \
  --deploy-mode cluster \
  --driver-memory 2G \
  --executor-memory 2G  \
  --num-executors 3 \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.yarn.appMasterEnv.PYSPARK_PYTHON=python3   \
  --conf spark.executorEnv.PYSPARK_PYTHON=python3   \
  --jars /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar,/home/exouser/jars/spark-sql-kafka-0-10_2.12-3.5.0.jar,/home/exouser/jars/kafka-clients-3.5.1.jar,/home/exouser/jars/spark-token-provider-kafka-0-10_2.12-3.5.0.jar,/home/exouser/jars/commons-pool2-2.11.1.jar   \
  --files /home/exouser/hadoop/etc/hadoop/core-site.xml,/home/exouser/hadoop/etc/hadoop/hdfs-site.xml,/home/exouser/spark/conf/hive-site.xml   btc_stream_consumer.py