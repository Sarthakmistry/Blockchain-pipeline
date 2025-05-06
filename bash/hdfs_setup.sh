sudo ufw default deny incoming
sudo ufw default allow outgoing

# 2) Allow all inter‑node traffic on your private subnet
#    Replace <PRIVATE_CIDR> with your Jetstream2 network, e.g. 10.0.0.0/24
sudo ufw allow from 10.1.174.61/24


# 3) Allow SSH only from your laptop
#    First, find your public IP (on your laptop): curl ifconfig.me
#    Then:
sudo ufw allow from 73.146.19.6/32 to any port 22 proto tcp

# 4) Expose HTTP for dashboards/UI
sudo ufw allow 80/tcp

# 5) (Optional) Expose Trino’s UI on 8080
sudo ufw allow 8080/tcp

# 6) Enable the firewall
sudo ufw enable

# 7) Check status
sudo ufw status verbose


# Installing Hadoop:

#RSA
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub smistry-worker-1-of-2
ssh-copy-id -i ~/.ssh/id_rsa.pub smistry-worker-2-of-2

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

wget https://downloads.apache.org/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz
tar zxvf hadoop-3.3.5.tar.gz

#Syncing files across the cluster:
rsync -av hadoop/ smistry-worker-1-of-2:~
rsync -av hadoop/ smistry-worker-2-of-2:~

# Setting environment variables:
nano .bashrc
#Inside bashrc add the following
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=$HOME/hadoop #different in worker nodes- it is just $HOME
export PATH=$PATH:$JAVA_HOME/bin
# Anytime you make any changes to bashrc you have to source it to save the changes
source ~/.bashrc

# adding IP addresses of all nodes in etc/hosts
10.1.174.61 master
10.1.174.210 worker1
10.1.174.197 worker2

# the core-site config:
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://master:9000</value>
  </property>

# the hdfs-site config is different on all nodes of the cluster

# Library IP address
149.160.218.241

# start hdfs
$HADOOP_HOME/sbin/start-dfs.sh
#stop hdfs
$HADOOP_HOME/sbin/stop-dfs.sh


#command to put model in hdfs:
hdfs dfs -mkdir -p /models/btc_anomaly_model
hdfs dfs -put models/bitcoin_anomaly_kmeans/* /models/btc_anomaly_model/

