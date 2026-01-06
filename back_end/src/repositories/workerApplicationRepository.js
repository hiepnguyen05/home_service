const { sequelize, Op } = require('../config/database');
const initModels = require('../models/init-models');

const models = initModels(sequelize);

class WorkerApplicationRepository {
    // Tạo đơn đăng ký worker mới
    async createApplication(applicationData) {
        return await models.worker_applications.create(applicationData);
    }

    // Lấy đơn đăng ký theo user ID
    async getApplicationByUserId(userId) {
        return await models.worker_applications.findOne({
            where: { user_id: userId },
            order: [['createdAt', 'DESC']]
        });
    }

    // Lấy đơn đăng ký theo ID
    async getApplicationById(applicationId) {
        return await models.worker_applications.findByPk(applicationId, {
            include: [
                {
                    model: models.users,
                    as: 'user',
                    attributes: { exclude: ['password_hash'] }
                },
                {
                    model: models.users,
                    as: 'reviewer',
                    attributes: ['id', 'full_name', 'email']
                }
            ]
        });
    }

    // Lấy danh sách tất cả đơn đăng ký với filter
    async getAllApplications(options = {}) {
        const {
            page = 1,
            limit = 10,
            status = null,
            sortBy = 'createdAt',
            sortOrder = 'DESC'
        } = options;

        const offset = (page - 1) * limit;
        const whereClause = {};

        if (status) {
            whereClause.status = status;
        }

        const { count, rows } = await models.worker_applications.findAndCountAll({
            where: whereClause,
            include: [
                {
                    model: models.users,
                    as: 'user',
                    attributes: { exclude: ['password_hash'] }
                }
            ],
            order: [[sortBy, sortOrder]],
            limit: parseInt(limit),
            offset: parseInt(offset)
        });

        return {
            applications: rows,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(count / limit),
                totalApplications: count,
                limit: parseInt(limit)
            }
        };
    }

    // Cập nhật trạng thái đơn đăng ký
    async updateApplicationStatus(applicationId, status, adminNote = null, reviewerId = null) {
        const updateData = {
            status,
            reviewed_at: new Date()
        };

        if (adminNote) {
            updateData.admin_note = adminNote;
        }

        if (reviewerId) {
            updateData.reviewed_by = reviewerId;
        }

        const [updatedRows] = await models.worker_applications.update(updateData, {
            where: { id: applicationId }
        });

        return updatedRows;
    }

    // Kiểm tra user đã có đơn đăng ký pending chưa
    async hasPendingApplication(userId) {
        const application = await models.worker_applications.findOne({
            where: {
                user_id: userId,
                status: 'pending'
            }
        });

        return !!application;
    }

    // Lấy thống kê đơn đăng ký
    async getApplicationStats() {
        const total = await models.worker_applications.count();
        const pending = await models.worker_applications.count({ where: { status: 'pending' } });
        const approved = await models.worker_applications.count({ where: { status: 'approved' } });
        const rejected = await models.worker_applications.count({ where: { status: 'rejected' } });

        return {
            total,
            pending,
            approved,
            rejected
        };
    }

    // Lấy đơn đăng ký theo trạng thái
    async getApplicationsByStatus(status, options = {}) {
        const {
            page = 1,
            limit = 10,
            sortBy = 'createdAt',
            sortOrder = 'DESC'
        } = options;

        const offset = (page - 1) * limit;

        const { count, rows } = await models.worker_applications.findAndCountAll({
            where: { status },
            include: [
                {
                    model: models.users,
                    as: 'user',
                    attributes: { exclude: ['password_hash'] }
                }
            ],
            order: [[sortBy, sortOrder]],
            limit: parseInt(limit),
            offset: parseInt(offset)
        });

        return {
            applications: rows,
            pagination: {
                currentPage: parseInt(page),
                totalPages: Math.ceil(count / limit),
                totalApplications: count,
                limit: parseInt(limit)
            }
        };
    }
}

module.exports = new WorkerApplicationRepository();