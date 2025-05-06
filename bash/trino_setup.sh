
wget https://repo1.maven.org/maven2/io/trino/trino-server/418/trino-server-443.tar.gz
tar zxvf trino-server-443.tar.gz
mv trino-server-443 trino


rsync -av trino/ worker1:~/trino
rsync -av trino/ worker2:~/trino

#Trino CLI:
wget https://repo1.maven.org/maven2/io/trino/trino-cli/418/trino-cli-443-executable.jar
mv trino-cli-443-executable.jar trino
chmod +x trino


#Start trino
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ~/trino/bin/launcher start
#Stop Trino
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 ~/trino/bin/launcher stop


#trino UI:
http://149.165.151.115:8090

#Command to access trino CLI
~/trino/bin/trino-cli \
  --server http://149.165.151.115:8090 \
  --catalog hive \
  --schema default

SHOW CATALOGS;
USE hive.default;
SHOW TABLES;


spark-shell \
  --jars /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar \
  --conf "spark.sql.catalogImplementation=hive" \
  --conf "javax.jdo.option.ConnectionURL=jdbc:mysql://localhost:3306/metastore_db?createDatabaseIfNotExist=true" \
  --conf "javax.jdo.option.ConnectionDriverName=com.mysql.cj.jdbc.Driver" \
  --conf "javax.jdo.option.ConnectionUserName=hive" \
  --conf "javax.jdo.option.ConnectionPassword=hivepassword" \
  --conf "hive.metastore.uris=thrift://10.1.174.61:9083"


spark-submit \
  --class org.apache.hudi.hive.HiveSyncTool \
  --jars /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar,/home/exouser/mysql-connector-j-9.3.0/mysql-connector-j-9.3.0.jar \
  /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar \
  --table block_tx_stream \
  --base-path hdfs://10.1.174.61:9000/user/stream/block_tx_stream \
  --use-jdbc \
  --jdbc-url jdbc:mysql://localhost:3306/metastore_db \
  --user hive \
  --pass hivepassword \
  --database default


spark-submit \
  --class org.apache.hudi.hive.HiveSyncTool \
  --jars /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar,/home/exouser/mysql-connector-j-9.3.0/mysql-connector-j-9.3.0.jar \
  /home/exouser/jars/hudi-spark3.5-bundle_2.12-0.15.0.jar \
  --table block_tx_stream \
  --base-path hdfs://10.1.174.61:9000/user/stream/block_tx_stream \
  --database default \
  --partitioned-by '' \
  --metastore-uri thrift://10.1.174.61:9083