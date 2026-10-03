const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3002;

app.use(cors());

app.use((req, res, next) => {
    res.setHeader('X-Backend', 'B');
    next();
});

app.get('/', (req, res) => {
    res.json({
        message: "Welcome to Backend Service B",
        host: "Mac 4 (Jayadeep - 10.16.13.71)"
    });
});

app.get('/api/status', (req, res) => {
    res.json({ backend: "B", status: "ok" });
});

app.get('/cache-test', (req, res) => {
    res.setHeader('Cache-Control', 'public, max-age=60');
    res.setHeader('ETag', '"backend-b-v1"');
    res.json({
        message: "Cached response from Backend B",
        timestamp: new Date().toISOString()
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend B running on http://0.0.0.0:${PORT}`);
});