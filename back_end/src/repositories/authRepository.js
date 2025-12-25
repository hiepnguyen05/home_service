const { sequelize, Op } = require('../config/database');
const initModels = require('../models/init-models');

const models = initModels(sequelize);

class AuthRepository {
  // Tìm người dùng bằng email hoặc số điện thoại
  async findUserByIdentifier(identifier) {
    return await models.users.findOne({
      where: {
        [Op.or]: [
          { email: identifier },
          { phone: identifier }
        ]
      }
    });
  }

  // Tìm người dùng bằng email
  async findUserByEmail(email) {
    return await models.users.findOne({
      where: { email: email }
    });
  }

  // Tìm người dùng bằng số điện thoại
  async findUserByPhone(phone) {
    return await models.users.findOne({
      where: { phone: phone }
    });
  }

  // Tạo người dùng mới
  async createUser(userData) {
    return await models.users.create(userData);
  }
}

module.exports = new AuthRepository();