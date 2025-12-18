const { sequelize } = require('../config/database');
const initModels = require('./init-models');

// Khởi tạo tất cả các model
const models = initModels(sequelize);

module.exports = {
  ...models,
  sequelize
};