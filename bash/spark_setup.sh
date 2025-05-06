wget https://downloads.apache.org/spark/spark-3.5.5/spark-3.5.5-bin-hadoop3.tgz
tar zxvf spark-3.5.5-bin-hadoop3.tgz
mv spark-3.5.5-bin-hadoop3 spark


rsync -av spark/ worker1:~/spark
rsync -av spark/ worker2:~/spark

# On all nodes
cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
sudo nano $SPARK_HOME/conf/spark-env.sh

#In the file, this is added:
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export SPARK_MASTER_HOST=master
export SPARK_WORKER_MEMORY=4g
export SPARK_WORKER_CORES=2

#On master, mention the workers in spark cluster
sudo nano $SPARK_HOME/conf/workers

$SPARK_HOME/sbin/start-all.sh
$SPARK_HOME/sbin/stop-all.sh

# SparkUI
http://149.165.151.115:8080

