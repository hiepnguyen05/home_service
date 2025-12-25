const bcrypt = require('bcryptjs');
const { generateToken } = require('../utils/tokenUtils');
const authRepository = require('../repositories/authRepository');

class AuthService {
  // Mã hóa mật khẩu
  async hashPassword(password) {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
  }

  // So sánh mật khẩu
  async comparePassword(password, hash) {
    return await bcrypt.compare(password, hash);
  }

  // Tạo token JWT
  generateToken(user) {
    return generateToken({ 
      userId: user.id, 
      phone: user.phone, 
      email: user.email 
    });
  }

  // Tìm người dùng bằng email hoặc số điện thoại
  async findUserByIdentifier(identifier) {
    return await authRepository.findUserByIdentifier(identifier);
  }

  // Tìm người dùng bằng email
  async findUserByEmail(email) {
    return await authRepository.findUserByEmail(email);
  }

  // Tìm người dùng bằng số điện thoại
  async findUserByPhone(phone) {
    return await authRepository.findUserByPhone(phone);
  }

  // Tạo người dùng mới
  async createUser(userData) {
    return await authRepository.createUser(userData);
  }
}

module.exports = new AuthService();