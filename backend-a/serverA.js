const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3001;

app.use(cors());

app.use((req, res, next) => {
  res.setHeader('X-Backend', 'A');
  next();
});

app.get('/', (req, res) => {
  res.json({ 
    message: "Welcome to Backend Service A", 
    host: "Mac 3 (Mohit - 10.16.13.37)" 
  });
});

app.get('/api/status', (req, res) => {
  res.json({ backend: "A", status: "ok" });
});

app.get('/cache-test', (req, res) => {
  res.setHeader('Cache-Control', 'public, max-age=60');
  res.setHeader('ETag', '"backend-a-v1"');
  res.json({ 
    message: "Cached response from Backend A", 
    timestamp: new Date().toISOString() 
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend A running on http://0.0.0.0:${PORT}`);
});