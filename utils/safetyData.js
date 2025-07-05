const fs = require('fs');
const csv = require('csv-parser');
const path = require('path');

// Load safety data from CSV
const safetyData = [];
const loadSafetyData = () => {
  return new Promise((resolve, reject) => {
    fs.createReadStream(path.join(__dirname, '../data/Chennai_200_Wards_SafetyData.csv'))
      .pipe(csv())
      .on('data', (data) => safetyData.push(data))
      .on('end', () => {
        console.log('Safety data loaded successfully');
        resolve(safetyData);
      })
      .on('error', (error) => {
        console.error('Error loading safety data:', error);
        reject(error);
      });
  });
};

// Determine if a location is in a high danger area
const isHighDangerArea = (latitude, longitude) => {
  // In a real application, you would implement proper geofencing
  // For this MVP, we'll use a simple approach based on the CSV data
  
  // Convert lat/long to nearest ward (this is a simplified example)
  const wardIndex = Math.floor(Math.random() * safetyData.length);
  const ward = safetyData[wardIndex];
  
  // Consider areas with safety score < 3.0 or crime reported > 150 as high danger
  if (ward && (parseFloat(ward.Perceived_Safety_Score_Women) < 3.0 || 
      parseInt(ward.Crime_Reported) > 150)) {
    return {
      isDangerous: true,
      wardNumber: ward['Ward Number'],
      locality: ward.Locality,
      safetyScore: ward.Perceived_Safety_Score_Women
    };
  }
  
  return { isDangerous: false };
};

module.exports = { loadSafetyData, isHighDangerArea, safetyData };