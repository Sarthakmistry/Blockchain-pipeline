This project implements a real-time data pipeline that ingests, processes, and analyzes unconfirmed Bitcoin transactions using Apache Kafka, Spark Structured Streaming, and machine learning. The goal is to perform live anomaly detection on blockchain transactions and enable batch querying via a structured storage format.

![image](https://github.com/user-attachments/assets/34a48f42-ec9c-48d1-8d69-4f63343f22e9)


├── bit_producer.py              # Connects to WebSocket API and pushes data to Kafka
├── btc_stream_consumer.py      # Spark Structured Streaming consumer for live transactions
├── Model_training.py           # Applies SparkML models for clustering or anomaly detection
├── sample_data_exploration.ipynb  # Initial data exploration in Jupyter
├── RunCommands.sh              # Script to run producers and consumers
├── bash/                       # Utility scripts (e.g., HDFS, Kafka commands)
├── config_files/               # Configurations for Kafka, Spark, Trino, etc.
├── models/                     # Saved ML model

