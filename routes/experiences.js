const express = require('express');
const router = express.Router();
const Experience = require('../models/Experience');
const auth = require('../middleware/auth');

// Get all experiences
router.get('/', async (req, res) => {
  try {
    const experiences = await Experience.find().sort({ createdAt: -1 });
    res.json(experiences);
  } catch (error) {
    console.error('Error fetching experiences:', error);
    res.status(500).json({ message: 'Server error fetching experiences' });
  }
});

// Add new experience
router.post('/', auth, async (req, res) => {
  try {
    const { name, story } = req.body;
    
    const experience = new Experience({
      name,
      story,
      userId: req.user.userId
    });
    
    await experience.save();
    res.status(201).json(experience);
  } catch (error) {
    console.error('Error adding experience:', error);
    res.status(500).json({ message: 'Server error adding experience' });
  }
});

module.exports = router;