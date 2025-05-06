sudo apt install screen
wget https://downloads.apache.org/kafka/3.9.0/kafka_2.13-3.9.0.tgz
tar zxvf kafka_2.13-3.9.0.tgz

rsync -av kafka/ smistry-worker-1-of-2:~/kafka/
rsync -av kafka/ smistry-worker-2-of-2:~/kafka/

#Added kafka enviroment variables
sudo nano .bashrc
source .bashrc

#Installing and configuring zookeeper
sudo mkdir -p /var/lib/zookeeper
sudo chown -R $USER:$USER /var/lib/zookeeper

#Configuring zookeeper ensemble
sudo nano $KAFKA_HOME/config/zookeeper.properties

#For Master
echo 1 | sudo tee /var/lib/zookeeper/myid
#For Worker1
echo 2 | sudo tee /var/lib/zookeeper/myid
#For Worker2
echo 3 | sudo tee /var/lib/zookeeper/myid

zkServerStart="$KAFKA_HOME/bin/zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties"
eval $zkServerStart

#Faced issues with port so updated firewall rules
sudo ufw allow from 10.1.174.0/24 to any port 2181 proto tcp




############################################################################################
#Command to stop zookeeper:
$KAFKA_HOME/bin/zookeeper-server-stop.sh   $KAFKA_HOME/config/zookeeper.properties
#Command to start zookeeper:
$KAFKA_HOME/bin/zookeeper-server-start.sh   $KAFKA_HOME/config/zookeeper.properties
############################################################################################


#Setting up Kafka
#Making changes in server configuration
sudo nano $KAFKA_HOME/config/server.properties


############################################################################################
#Command to stop kafka:
$KAFKA_HOME/bin/kafka-server-stop.sh $KAFKA_HOME/config/server.properties
#Command to start kafka:
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
############################################################################################




#Command for viewing streams in console
bin/kafka-console-consumer.sh   --bootstrap-server master:9092   --topic wikinews.recentchange   --from-beginning

#Command for viewing list of kafka topic:
$KAFKA_HOME/bin/kafka-topics.sh --list --bootstrap-server master:9092

#Command for deleting a Kafka topic
$KAFKA_HOME/bin/kafka-topics.sh --delete --bootstrap-server master:9092 --topic wiki-recentchange


#Command to create the topic
$KAFKA_HOME/bin/kafka-topics.sh --create \
  --bootstrap-server master:9092 \
  --replication-factor 3 \
  --partitions 3 \
  --topic blockchain.txs

$KAFKA_HOME/bin/kafka-topics.sh --create --bootstrap-server master:9092 --replication-factor 3 --partitions 3 --topic blockchain.txs