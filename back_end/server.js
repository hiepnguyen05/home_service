const app = require('./src/app');
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Home Service API Server đang chạy!');
});

app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server đang hoạt động bình thường',
    timestamp: new Date().toISOString()
  });
});

const server = app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng http://localhost:${PORT}`);
});

// Dong server mot cach sang trong
process.on('SIGTERM', () => {
  console.log('Da nhan SIGTERM, dang dong server sang trong');
  server.close(() => {
    console.log('Qua trinh da ket thuc');
  });
});

process.on('SIGINT', () => {
  console.log('Da nhan SIGINT, dang dong server sang trong');
  server.close(() => {
    console.log('Qua trinh da ket thuc');
  });
});