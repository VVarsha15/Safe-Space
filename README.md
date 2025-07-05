# SafeSpace

SafeSpace is a cross-platform safety monitoring application that integrates real-time heart rate analysis, fear detection using machine learning, GPS-based location awareness, and a secure backend to store user experiences and emergency information. The system combines a mobile frontend (Flutter), machine learning backend (Python), and a REST API (Node.js + MongoDB), along with hardware support through Arduino and a pulse sensor.

---

## Project Features

- Real-time heart rate monitoring via a pulse sensor connected to Arduino
- Detection of abnormal/fear conditions using HRV features and logistic regression
- GPS location tracker with zone-based warnings
- Emergency contact data collection and optional SOS alert integration
- Experience sharing and viewing forum
- Secure login/signup system with backend integration
- Data logging and retraining of machine learning model

---

## Requirements

### Hardware
- Arduino UNO
- Pulse Sensor (e.g., PulseSensor Amped)
- Jumper wires
- USB cable
- Optional: SIM800L GSM module for emergency SMS alerts
- Optional: NEO-6M GPS module for GPS location detection

### Software
- Flutter SDK (3.0+ recommended)
- Python 3.9+
- Node.js 18+ (with npm)
- MongoDB Community Server
- Git

---

## Running the Project

### 1. Arduino Setup

- Connect the pulse sensor:
  - Signal → A0
  - VCC → 3.3V or 5V
  - GND → GND
- Upload the `heart_rate_sensor.ino` sketch via Arduino IDE
- Open Serial Monitor to verify output like `BPM: 78`

### 2. Python Backend

```bash
pip install pandas numpy scikit-learn pyserial joblib
python real_time_model.py
```
This will:

Read BPM from serial

Log HRV features

Save to bpm_output.json 

### 3. Node.js + MongoDB API

```bash
npm install
node server.js
```

MongoDB stores user info and safety experiences via REST API.

### 4. Flutter App
```bash
flutter pub get
flutter run -d <device>    # windows, android, or emulator
```
The UI includes login/signup, home dashboard, BPM display, GPS tracker, and safety forum.

## Machine Learning Info
Features used: SD1, SD2, SampEn, Higuchi

Logistic Regression model trained on both preloaded and live HRV data

Data stored in bpm_log.csv and retrained periodically

## APIs (Node.js)
POST /signup — Create user

POST /experience — Add safety experience

GET /experience — View all user posts

(Optional Flask route) GET /bpm — Serve live BPM + fear status

##Arduino
Install Arduino IDE and run heart_rate_sensor.txt in it and connect accordingly

## Important Notes
Project requires a working Arduino + pulse sensor for heart rate monitoring to function

If bpm_output.json isn't updating, check that real_time_model.py is running

MongoDB must be running for login, signup, and experience posting

## License
Free to use for academic, research, and personal safety projects.


