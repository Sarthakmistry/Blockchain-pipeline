# Real-Time Blockchain Transaction Analysis Pipeline

This project implements a **real-time data pipeline** that ingests, processes, and analyzes unconfirmed Bitcoin transactions using:

- **Apache Kafka**
- **Spark Structured Streaming**
- **Apache Hudi on HDFS**
- **SparkML for anomaly detection**
- **Trino (v418) for SQL querying**

The goal is to perform **live anomaly detection** on blockchain transactions and enable fast, structured batch queries.

---

## Architecture Overview

![image](https://github.com/user-attachments/assets/34a48f42-ec9c-48d1-8d69-4f63343f22e9)

---

## Components Breakdown

- `bit_producer.py` – Connects to Blockchain WebSocket API and pushes transactions to Kafka  
- `btc_stream_consumer.py` – Spark Structured Streaming job that consumes data from Kafka  
- `Model_training.py` – Trains and saves SparkML (KMeans) clustering model for anomaly detection  
- `sample_data_exploration.ipynb` – Offline feature exploration and schema design  
- `RunCommands.sh` – Bash script to launch services and jobs  
- `bash/` – Utility scripts (HDFS formatters, Kafka runners, etc.)  
- `config_files/` – Configurations for Kafka, Spark, Hudi, Trino  
- `models/` – Saved SparkML models used for real-time inference  

---

## Technologies Used

| Technology | Role |
|------------|------|
| Kafka | Ingest live blockchain transactions |
| Spark Structured Streaming | Process and transform streaming data |
| SparkML | Detect anomalous transactions in real time |
| Hudi + HDFS | Store processed data in a versioned, queryable format |
| Trino | Perform ad hoc SQL queries on Hudi tables |
| Hive Metastore + MySQL | Manage metadata for Trino-Hudi integration |

---

## Features

- Ingests live transactions via WebSocket → Kafka
- Spark processes transactions in real time
- Unsupervised ML flags anomalies on-the-fly
- Stored in partitioned Hudi tables
- SQL analytics powered by Trino

---
