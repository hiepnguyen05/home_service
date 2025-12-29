require('dotenv').config();

// Cấu hình cho Sequelize CLI
module.exports = {
  development: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: false,
  },
  test: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
  },
  production: {
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
  }
};

// Cấu hình cho kết nối trực tiếp
const { Sequelize, Op } = require('sequelize');
const initModels = require('../models/init-models');

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

// Khởi tạo tất cả models
const models = initModels(sequelize);

// Kiểm tra kết nối
const connectDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('Đã kết nối đến cơ sở dữ liệu thành công!');
    console.log('Đã khởi tạo tất cả models từ database!');
  } catch (error) {
    console.error('Không thể kết nối đến cơ sở dữ liệu:', error.message);
    process.exit(1);
  }
};

module.exports.sequelize = sequelize;
module.exports.models = models;
module.exports.Op = Op;
module.exports.connectDB = connectDB;