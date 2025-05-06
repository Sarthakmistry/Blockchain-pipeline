#!/bin/bash

# --- Configuration ---
KAFKA_LOG_DIR="/media/volume/kafka-logs"
SPARK_LOG_DIR="/tmp/spark-events"
TRINO_LOG_DIR="$HOME/trino/var/log"
TODAY=$(date '+%Y-%m-%d')
OLDER_THAN_DATE=$(date -d "yesterday" '+%Y-%m-%d')

echo "Starting cleanup at $(date)"
echo "Today's date: $TODAY | Removing logs older than: $OLDER_THAN_DATE"
echo "-------------------------------------------------------------"

# --- Kafka: Remove old segment logs ---
echo "[Kafka] Cleaning old log segments older than 24h from $KAFKA_LOG_DIR"
find "$KAFKA_LOG_DIR" -type f -name '*.log' -mtime +1 -exec rm -v {} \;

# --- Spark: Remove local Spark event logs older than 1 day ---
if [ -d "$SPARK_LOG_DIR" ]; then
  echo "[Spark] Removing Spark event logs older than 1 day in $SPARK_LOG_DIR"
  find "$SPARK_LOG_DIR" -type f -mtime +1 -exec rm -v {} \;
else
  echo "[Spark] No spark log dir at $SPARK_LOG_DIR"
fi

# --- Trino: Clean launcher logs older than 1 day ---
if [ -d "$TRINO_LOG_DIR" ]; then
  echo "[Trino] Removing logs older than 1 day from $TRINO_LOG_DIR"
  find "$TRINO_LOG_DIR" -type f -mtime +1 -exec rm -v {} \;
else
  echo "[Trino] No Trino log dir at $TRINO_LOG_DIR"
fi

echo "Cleanup completed at $(date)"