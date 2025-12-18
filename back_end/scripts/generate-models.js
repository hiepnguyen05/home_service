const SequelizeAuto = require('sequelize-auto');
require('dotenv').config();

// Cấu hình kết nối database
const auto = new SequelizeAuto(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    directory: './src/models', // Thư mục để lưu các model
    additional: {
      timestamps: true,
    },
    // Bỏ qua các bảng nếu cần
    // tables: ['users', 'services'] // Chỉ tạo model cho các bảng cụ thể
  }
);

console.log('Đang tạo model từ database...');
auto.run().then(data => {
  console.log('Tạo model thành công!');
  console.log('Các bảng đã tạo model:', Object.keys(data.tables));
}).catch(err => {
  console.error('Lỗi khi tạo model:', err);
});