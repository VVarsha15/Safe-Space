import serial
import time
import numpy as np
import pandas as pd
import json
import requests
from sklearn.linear_model import LogisticRegression
from collections import deque

# === Settings ===
PORT = 'COM3'  # Replace with your actual COM port
BAUD_RATE = 9600
WINDOW_SIZE = 10
bpm_log_file = 'bpm_log.csv'
json_output_file = 'bpm_output.json'
NODE_SERVER_URL = 'http://localhost:3000/heart-rate-update'  # Server URL

# === Setup Serial ===
print("🔌 Connecting to Arduino...")
try:
    ser = serial.Serial(PORT, BAUD_RATE, timeout=1)
    time.sleep(2)  # Allow Arduino to initialize
    print("✅ Connected to Arduino")
except Exception as e:
    print(f"❌ Failed to connect to Arduino: {e}")
    ser = None

# === Load Pretrained Data ===
def load_pretrained_data():
    try:
        df = pd.read_csv('realtime_training_data.csv')
        if 'label' not in df.columns:
            df['label'] = df['label'].apply(lambda x: 1 if x == 1 else 0)
        X = df[['SD1', 'SD2', 'sampen', 'higuci']]
        y = df['label']
        return X, y
    except Exception as e:
        print(f"⚠️ Error loading training data: {e}")
        # Create empty training data
        return pd.DataFrame(columns=['SD1', 'SD2', 'sampen', 'higuci']), pd.Series([], dtype='int')

# === Feature Extraction ===
def extract_hrv_features(bpm_list):
    ibi_series = 60000 / np.array(bpm_list)
    sd1 = np.std(np.diff(ibi_series)) / np.sqrt(2)
    sd2 = np.std(ibi_series)
    sampen = np.std(np.diff(ibi_series)) / (np.mean(np.diff(ibi_series)) + 1e-6)
    higuchi = np.log(np.var(ibi_series) + 1e-6)
    return [sd1, sd2, sampen, higuchi]

# === Ensure CSV exists BEFORE model training ===
try:
    pd.read_csv(bpm_log_file, on_bad_lines='skip')
except FileNotFoundError:
    with open(bpm_log_file, 'w') as f:
        f.write('timestamp,BPM,label\n')

# === Train Model ===
def train_model():
    X_train, y_train = load_pretrained_data()
    try:
        new_df = pd.read_csv(bpm_log_file)
        new_df = new_df.dropna()
        if 'label' not in new_df.columns:
            new_df['label'] = 0

        feature_rows = []
        for i in range(WINDOW_SIZE, len(new_df)):
            recent_bpms = new_df['BPM'].astype(float).values[i - WINDOW_SIZE:i]
            label = new_df['label'].values[i]
            features = extract_hrv_features(recent_bpms)
            feature_rows.append(features + [label])

        if not feature_rows:
            print("⚠️ Not enough real-time data yet to retrain model.")
            return None

        df_features = pd.DataFrame(feature_rows, columns=['SD1', 'SD2', 'sampen', 'higuci', 'label'])
        
        if not X_train.empty:
            X_combined = pd.concat([X_train, df_features[['SD1', 'SD2', 'sampen', 'higuci']]])
            y_combined = pd.concat([y_train, df_features['label']])
        else:
            X_combined = df_features[['SD1', 'SD2', 'sampen', 'higuci']]
            y_combined = df_features['label']

        model = LogisticRegression(max_iter=1000)
        model.fit(X_combined, y_combined)
        print("✅ Model trained with real-time and pretrained data.")
        return model

    except Exception as e:
        print(f"⚠️ Error while training model: {e}")
        return None

# === Initialize Variables ===
bpm_history = deque(maxlen=WINDOW_SIZE)
model = train_model()
last_bpm = 0
last_timestamp = time.time()

# === Real-Time Fear Detection ===
def detect_fear(bpm, last_bpm, last_timestamp):
    bpm_history.append(bpm)
    current_timestamp = time.time()
    bpm_rate_of_change = bpm - last_bpm
    time_diff = current_timestamp - last_timestamp

    if bpm_rate_of_change > 10 and time_diff < 3:
        return True
    elif len(bpm_history) == WINDOW_SIZE and model:
        features = extract_hrv_features(bpm_history)
        prediction = model.predict([features])[0]
        return prediction == 1
    return False

# === Send data to Node.js server ===
def send_to_node_server(bpm, fear_detected):
    try:
        data = {"bpm": bpm, "fear": fear_detected}
        response = requests.post(NODE_SERVER_URL, json=data, 
                                headers={"Content-Type": "application/json"})
        if response.status_code == 200:
            print("✅ Data sent to Node.js server")
        else:
            print(f"⚠️ Failed to send data to Node.js server: {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"⚠️ Error sending data to Node.js server: {e}")

# === Main Loop ===
print("🚀 Real-Time Heart Rate Monitoring Started...")
print(f"📡 Will send data to: {NODE_SERVER_URL}")
try:
    while True:
        if ser and ser.in_waiting > 0:
            line = ser.readline().decode('utf-8', errors='replace').strip()
            print(f"📡 RAW LINE: {line}")  # Debug: See incoming data

            if "BPM" in line:
                print(f"✅ BPM line received: {line}")
                try:
                    parts = line.split(":")
                    if len(parts) == 2:
                        bpm_val = float(parts[1].strip())
                        timestamp = time.time()
                        print(f"📈 Parsed BPM: {bpm_val}")

                        # Append to CSV log
                        with open(bpm_log_file, 'a') as f:
                            f.write(f"{timestamp},{bpm_val},0\n")

                        # Detect fear
                        fear_detected = detect_fear(bpm_val, last_bpm, last_timestamp)
                        status = "⚠️ FEAR DETECTED!" if fear_detected else "✅ Normal"
                        print(f"❤️ BPM: {bpm_val:.2f} → {status}")

                        # Write to JSON for Flutter
                        with open(json_output_file, "w") as json_file:
                            json.dump({"bpm": bpm_val, "fear": fear_detected}, json_file)
                            
                        # Send to Node.js server
                        send_to_node_server(bpm_val, fear_detected)

                        last_bpm = bpm_val
                        last_timestamp = timestamp

                except ValueError as ve:
                    print(f"⚠️ Could not parse BPM: {ve}")
        else:
            # Simulate data for testing when no Arduino connection
            if ser is None:
                time.sleep(1)
                bpm_val = 75 + (np.random.random() * 10)
                timestamp = time.time()
                fear_detected = detect_fear(bpm_val, last_bpm, last_timestamp)
                
                # Write to JSON
                with open(json_output_file, "w") as json_file:
                    json.dump({"bpm": bpm_val, "fear": fear_detected}, json_file)
                
                # Send to Node.js server
                send_to_node_server(bpm_val, fear_detected)
                
                last_bpm = bpm_val
                last_timestamp = timestamp
                print(f"❤️ Simulated BPM: {bpm_val:.2f}")

        time.sleep(0.1)

except KeyboardInterrupt:
    print("\n🛑 Stopped by user.")
    if ser:
        ser.close()