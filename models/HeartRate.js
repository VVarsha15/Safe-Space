const mongoose = require('mongoose');

const HeartRateSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  bpm: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now },
  fearDetected: { type: Boolean, default: false }
});

module.exports = mongoose.model('HeartRate', HeartRateSchema);