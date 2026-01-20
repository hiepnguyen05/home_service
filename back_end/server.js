const app = require('./src/app');
const PORT = process.env.PORT || 3000;

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