This project implements a real-time data pipeline that ingests, processes, and analyzes unconfirmed Bitcoin transactions using Apache Kafka, Spark Structured Streaming, and machine learning. The goal is to perform live anomaly detection on blockchain transactions and enable batch querying via a structured storage format.

![Blank diagram](https://github.com/user-attachments/assets/b5700e4d-05dc-47b5-8958-ee7296d832f0)

├── bit_producer.py              # Connects to WebSocket API and pushes data to Kafka
├── btc_stream_consumer.py      # Spark Structured Streaming consumer for live transactions
├── Model_training.py           # Applies SparkML models for clustering or anomaly detection
├── bitcoin_transactions.csv    # Sample dataset (can be used for EDA)
├── sample_data_exploration.ipynb  # Initial data exploration in Jupyter
├── RunCommands.sh              # Script to run producers and consumers
├── bash/                       # Utility scripts (e.g., HDFS, Kafka commands)
├── config_files/               # Configurations for Kafka, Spark, Trino, etc.
├── models/                     # Saved or exported ML models

