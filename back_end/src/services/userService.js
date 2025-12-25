const userRepository = require('../repositories/userRepository');

class UserService {
  // Cập nhật hồ sơ người dùng
  async updateUserProfile(userId, profileData) {
    try {
      const updatedRows = await userRepository.updateProfile(userId, profileData);
      
      if (updatedRows === 0) {
        throw new Error('Không tìm thấy người dùng');
      }

      // Lấy dữ liệu người dùng đã cập nhật
      const updatedUser = await userRepository.findById(userId);
      return updatedUser;
    } catch (error) {
      throw new Error(`Không thể cập nhật hồ sơ người dùng: ${error.message}`);
    }
  }

  // Cập nhật địa chỉ người dùng
  async updateUserAddress(userId, addressData) {
    try {
      const savedAddress = await userRepository.findOrCreateAddress(userId, addressData);
      return savedAddress;
    } catch (error) {
      throw new Error(`Không thể cập nhật địa chỉ người dùng: ${error.message}`);
    }
  }

  // Lấy hồ sơ người dùng cùng với địa chỉ
  async getUserProfileWithAddresses(userId) {
    try {
      // Lấy dữ liệu người dùng
      const user = await userRepository.findById(userId);
      
      if (!user) {
        throw new Error('Không tìm thấy người dùng');
      }

      // Lấy địa chỉ của người dùng
      const addresses = await userRepository.findUserAddresses(userId);

      return {
        user,
        addresses
      };
    } catch (error) {
      throw new Error(`Không thể lấy hồ sơ người dùng: ${error.message}`);
    }
  }
}

module.exports = new UserService();