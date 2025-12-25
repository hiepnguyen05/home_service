const { sequelize, Op } = require('../config/database');
const initModels = require('../models/init-models');

const models = initModels(sequelize);

class UserRepository {
    // Tìm người dùng bằng ID
    async findById(userId) {
        return await models.users.findByPk(userId, {
            attributes: { exclude: ['password_hash'] } // Loại bỏ password khỏi kết quả
        });
    }

    // Cập nhật hồ sơ người dùng
    async updateProfile(userId, profileData) {
        const [updatedRows] = await models.users.update(profileData, {
            where: { id: userId }
        });
        return updatedRows;
    }

    // Tìm hoặc tạo địa chỉ người dùng
    async findOrCreateAddress(userId, addressData) {
        // Nếu đây là địa chỉ mặc định, cập nhật các địa chỉ khác thành không mặc định
        if (addressData.is_default) {
            await models.user_addresses.update(
                { is_default: false },
                { where: { user_id: userId } }
            );
        }

        // Tạo địa chỉ mới
        return await models.user_addresses.create({
            user_id: userId,
            ...addressData
        });
    }

    // Lấy tất cả địa chỉ của người dùng
    async findUserAddresses(userId) {
        return await models.user_addresses.findAll({
            where: { user_id: userId },
            order: [['is_default', 'DESC'], ['createdAt', 'DESC']]
        });
    }

    // Cập nhật địa chỉ
    async updateAddress(addressId, userId, addressData) {
        // Nếu đây là địa chỉ mặc định, cập nhật các địa chỉ khác thành không mặc định
        if (addressData.is_default) {
            await models.user_addresses.update(
                { is_default: false },
                { where: { user_id: userId } }
            );
        }

        const [updatedRows] = await models.user_addresses.update(addressData, {
            where: {
                id: addressId,
                user_id: userId
            }
        });
        return updatedRows;
    }

    // Xóa địa chỉ
    async deleteAddress(addressId, userId) {
        return await models.user_addresses.destroy({
            where: {
                id: addressId,
                user_id: userId
            }
        });
    }

    // Lấy địa chỉ mặc định của người dùng
    async getDefaultAddress(userId) {
        return await models.user_addresses.findOne({
            where: {
                user_id: userId,
                is_default: true
            }
        });
    }
}

module.exports = new UserRepository();