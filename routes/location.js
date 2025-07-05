const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { isHighDangerArea } = require('../utils/safetyData');

// Check if location is in danger area
router.post('/check-danger', auth, (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    
    if (!latitude || !longitude) {
      return res.status(400).json({ message: 'Latitude and longitude are required' });
    }
    
    const dangerCheck = isHighDangerArea(latitude, longitude);
    res.json(dangerCheck);
  } catch (error) {
    console.error('Error checking danger area:', error);
    res.status(500).json({ message: 'Server error checking danger area' });
  }
});

module.exports = router;