const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',        // your DB user
  password: '1518',        // your DB password
  database: 'safespace'  // your DB name
});

db.connect(err => {
  if (err) throw err;
  console.log("Connected to MySQL!");
});

// Login route
app.post('/login', (req, res) => {
  const { phone, password } = req.body;
  const sql = 'SELECT password FROM users WHERE phone = ?';
  
  db.query(sql, [phone], (err, results) => {
    if (err) return res.status(500).json({ status: 'error', message: err.message });

    if (results.length === 0) {
      return res.json({ status: 'not_found' });
    }

    if (results[0].password === password) {
      return res.json({ status: 'success' });
    } else {
      return res.json({ status: 'invalid_password' });
    }
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
