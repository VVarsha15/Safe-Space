const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Register a new user
router.post('/register', async (req, res) => {
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

// Login user
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;
    
    // Find user
    const user = await User.findOne({ phone });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Check password
    const isMatch = await user.comparePassword(password);
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

module.exports = router;