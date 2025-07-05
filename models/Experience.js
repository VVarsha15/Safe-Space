const mongoose = require('mongoose');

const ExperienceSchema = new mongoose.Schema({
  name: { type: String, required: true },
  story: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Experience', ExperienceSchema);