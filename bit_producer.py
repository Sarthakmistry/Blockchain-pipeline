import websocket
import json
from kafka import KafkaProducer

# Kafka Config
KAFKA_BROKER = "10.1.174.61:9092"
KAFKA_TOPIC = "blockchain.txs"

# Initialize Kafka producer
producer = KafkaProducer(
    bootstrap_servers=[KAFKA_BROKER],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# WebSocket event handlers
def on_open(ws):
    print("WebSocket connection opened.")
    subscribe_message = json.dumps({
        "op": "unconfirmed_sub"
    })
    ws.send(subscribe_message)

def on_message(ws, message):
    try:
        data = json.loads(message)
        if data.get("op") == "utx":
            producer.send(KAFKA_TOPIC, data["x"])
            print("Sent tx to Kafka:", data["x"]["hash"])
    except Exception as e:
        print("Error processing message:", e)

def on_error(ws, error):
    print("WebSocket error:", error)

def on_close(ws, close_status_code, close_msg):
    print("WebSocket connection closed.")

if __name__ == "__main__":
    ws_url = "wss://ws.blockchain.info/inv"

    ws = websocket.WebSocketApp(
        ws_url,
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )

    print("Starting WebSocket client...")
    ws.run_forever()