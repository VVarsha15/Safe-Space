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

## Folder Structure

