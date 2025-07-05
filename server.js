const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const http = require('http');
const socketIo = require('socket.io');
const fs = require('fs');
const path = require('path');

// Create Express app
const app = express();
const server = http.createServer(app);

// Enable CORS for all routes
app.use(cors({
  origin: '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-auth-token']
}));

// Parse JSON requests
app.use(express.json());

// Configure Socket.IO with CORS
const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/safespace', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.error('MongoDB connection error:', err));

// Create data directory if it doesn't exist
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
  fs.mkdirSync(dataDir);
}

// Define User schema
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  age: { type: Number, required: true },
  password: { type: String, required: true },
  emergencyContact: {
    name: { type: String, required: true },
    phone: { type: String, required: true },
    relation: { type: String, required: true }
  },
  createdAt: { type: Date, default: Date.now }
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

const User = mongoose.model('User', userSchema);

// Define Experience schema
const experienceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  story: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

const Experience = mongoose.model('Experience', experienceSchema);

// Auth routes
app.post('/api/auth/register', async (req, res) => {
  try {
    const { name, phone, age, password, emergencyContact } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists with this phone number' });
    }
    
    // Create new user
    const user = new User({
      name,
      phone,
      age,
      password,
      emergencyContact
    });
    
    await user.save();
    
    // Create token
    const token = jwt.sign({ userId: user._id }, 'your_jwt_secret', { expiresIn: '1d' });
    
    res.status(201).json({ token, userId: user._id });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ message: 'Server error during registration' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    
    // Find user
    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Check password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid password' });
    }
    
    // Create token
    const token = jwt.sign({ userId: user._id }, 'your_jwt_secret', { expiresIn: '1d' });
    
    res.json({ token, userId: user._id });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ message: 'Server error during login' });
  }
});

// Experiences routes
app.get('/api/experiences', async (req, res) => {
  try {
    const experiences = await Experience.find().sort({ createdAt: -1 });
    res.json(experiences);
  } catch (error) {
    console.error('Error fetching experiences:', error);
    res.status(500).json({ message: 'Server error fetching experiences' });
  }
});

app.post('/api/experiences', async (req, res) => {
  try {
    const { name, story } = req.body;
    
    const experience = new Experience({
      name,
      story,
      // userId will be added when auth is implemented properly
    });
    
    await experience.save();
    res.status(201).json(experience);
  } catch (error) {
    console.error('Error adding experience:', error);
    res.status(500).json({ message: 'Server error adding experience' });
  }
});

// Location routes
app.post('/api/location/check-danger', async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    
    console.log('Checking danger for location:', { latitude, longitude });
    
    // Simulate a random danger check
    const isDangerous = Math.random() > 0.7;
    
    res.json({
      isDangerous,
      wardNumber: isDangerous ? '45' : undefined,
      locality: isDangerous ? 'Locality_45' : undefined,
      safetyScore: isDangerous ? '2.5' : undefined
    });
  } catch (error) {
    console.error('Error checking danger area:', error);
    res.status(500).json({ message: 'Server error checking danger area' });
  }
});

// Heart rate update endpoint
app.post('/heart-rate-update', (req, res) => {
  const { bpm, fear } = req.body;
  
  console.log(`Received heart rate update: BPM=${bpm}, Fear=${fear}`);
  
  // Broadcast to all connected socket clients
  io.emit('heartRateUpdate', { bpm, fear });
  
  res.status(200).json({ message: 'Heart rate data received' });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Server is running' });
});

// Socket.io for real-time heart rate updates
io.on('connection', (socket) => {
  console.log('New client connected:', socket.id);
  
  socket.on('heartRateUpdate', (data) => {
    console.log('Received heart rate from socket:', data);
    // Broadcast to all clients
    io.emit('heartRateUpdate', data);
  });
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Start server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));