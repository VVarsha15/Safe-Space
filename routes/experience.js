const express = require('express');
const router = express.Router();
const Experience = require('../models/Experience');

router.post('/submit', async (req, res) => {
  try {
    const experience = new Experience(req.body);
    await experience.save();
    res.send({ success: true, message: 'Experience shared!' });
  } catch (err) {
    res.status(400).send({ success: false, message: err.message });
  }
});

router.get('/all', async (req, res) => {
  const experiences = await Experience.find().sort({ timestamp: -1 });
  res.send(experiences);
});

module.exports = router;
