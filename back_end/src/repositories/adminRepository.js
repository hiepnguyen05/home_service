const { sequelize, Op } = require('../config/database');
const initModels = require('../models/init-models');

const models = initModels(sequelize);

class AdminRepository {
    // Lấy danh sách tất cả người dùng với phân trang và lọc
    async getAllUsers(options = {}) {
        const {
            page = 1,
            limit = 10,
            role = null,
            status = null,
            search = null,
            sortBy = 'createdAt',
            sortOrder = 'DESC'
        } = options;

        const offset = (page - 1) * limit;
        const whereClause = {};

        // Lọc theo role
        if (role) {
            whereClause.role = role;
        }

        // Lọc theo status
        if (status) {
            whereClause.status = status;
        }

        // Tìm kiếm theo tên, email, phone
        if (search) {
            whereClause[Op.or] = [
                { full_name: { [Op.like]: `%${search}%` } },
                { email: { [Op.like]: `%${search}%` } },
                { phone: { [Op.like]: `%${search}%` } }
            ];
        }

        const { count, rows } = await models.users.findAndCountAll({
            where: whereClause,
            attributes: { exclude: ['password_hash'] },
            order: [[sortBy, sortOrder]],
            limit: parseInt(limit),
            offset: parseInt(offset)
        });

        return {
            users: rows,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(count / limit),
                totalUsers: count,
                limit: parseInt(limit)
            }
        };
    }

    // Lấy thông tin chi tiết một người dùng
    async getUserById(userId) {
        return await models.users.findByPk(userId, {
            attributes: { exclude: ['password_hash'] },
            include: [
                {
                    model: models.user_addresses,
                    as: 'user_addresses'
                }
            ]
        });
    }

    // Cập nhật thông tin người dùng
    async updateUser(userId, updateData) {
        const [updatedRows] = await models.users.update(updateData, {
            where: { id: userId }
        });
        return updatedRows;
    }

    // Cập nhật trạng thái người dùng
    async updateUserStatus(userId, status) {
        const [updatedRows] = await models.users.update(
            { status },
            { where: { id: userId } }
        );
        return updatedRows;
    }

    // Cập nhật role người dùng
    async updateUserRole(userId, role) {
        const [updatedRows] = await models.users.update(
            { role },
            { where: { id: userId } }
        );
        return updatedRows;
    }

    // Xóa mềm người dùng (soft delete)
    async softDeleteUser(userId) {
        return await models.users.destroy({
            where: { id: userId }
        });
    }

    // Khôi phục người dùng đã xóa mềm
    async restoreUser(userId) {
        return await models.users.restore({
            where: { id: userId }
        });
    }

    // Xóa cứng người dùng (hard delete)
    async hardDeleteUser(userId) {
        return await models.users.destroy({
            where: { id: userId },
            force: true
        });
    }

    // Thống kê người dùng
    async getUserStats() {
        const totalUsers = await models.users.count();
        const activeUsers = await models.users.count({ where: { status: 'active' } });
        const inactiveUsers = await models.users.count({ where: { status: 'inactive' } });
        const bannedUsers = await models.users.count({ where: { status: 'banned' } });
        const pendingUsers = await models.users.count({ where: { status: 'pending_verification' } });

        const customerCount = await models.users.count({ where: { role: 'customer' } });
        const workerCount = await models.users.count({ where: { role: 'worker' } });
        const adminCount = await models.users.count({ where: { role: 'admin' } });

        return {
            total: totalUsers,
            byStatus: {
                active: activeUsers,
                inactive: inactiveUsers,
                banned: bannedUsers,
                pending_verification: pendingUsers
            },
            byRole: {
                customer: customerCount,
                worker: workerCount,
                admin: adminCount
            }
        };
    }

    // Tạo tài khoản admin mới
    async createAdmin(adminData) {
        return await models.users.create({
            ...adminData,
            role: 'admin',
            status: 'active'
        });
    }

    // Lấy danh sách người dùng đã xóa mềm
    async getDeletedUsers(options = {}) {
        const {
            page = 1,
            limit = 10
        } = options;

        const offset = (page - 1) * limit;

        const { count, rows } = await models.users.findAndCountAll({
            where: {},
            attributes: { exclude: ['password_hash'] },
            paranoid: false, // Bao gồm cả records đã xóa mềm
            order: [['deletedAt', 'DESC']],
            limit: parseInt(limit),
            offset: parseInt(offset)
        });

        // Lọc chỉ những record đã bị xóa mềm
        const deletedUsers = rows.filter(user => user.deletedAt !== null);

        return {
            users: deletedUsers,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(deletedUsers.length / limit),
                totalUsers: deletedUsers.length,
                limit: parseInt(limit)
            }
        };
    }

    // Tìm kiếm người dùng nâng cao
    async advancedSearch(searchCriteria) {
        const {
            fullName,
            email,
            phone,
            role,
            status,
            createdFrom,
            createdTo,
            page = 1,
            limit = 10
        } = searchCriteria;

        const whereClause = {};
        const offset = (page - 1) * limit;

        if (fullName) {
            whereClause.full_name = { [Op.like]: `%${fullName}%` };
        }

        if (email) {
            whereClause.email = { [Op.like]: `%${email}%` };
        }

        if (phone) {
            whereClause.phone = { [Op.like]: `%${phone}%` };
        }

        if (role) {
            whereClause.role = role;
        }

        if (status) {
            whereClause.status = status;
        }

        if (createdFrom || createdTo) {
            whereClause.createdAt = {};
            if (createdFrom) {
                whereClause.createdAt[Op.gte] = new Date(createdFrom);
            }
            if (createdTo) {
                whereClause.createdAt[Op.lte] = new Date(createdTo);
            }
        }

        const { count, rows } = await models.users.findAndCountAll({
            where: whereClause,
            attributes: { exclude: ['password_hash'] },
            order: [['createdAt', 'DESC']],
            limit: parseInt(limit),
            offset: parseInt(offset)
        });

        return {
            users: rows,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(count / limit),
                totalUsers: count,
                limit: parseInt(limit)
            }
        };
    }
}

module.exports = new AdminRepository();