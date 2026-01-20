const workerApplicationRepository = require('../repositories/workerApplicationRepository');
const userRepository = require('../repositories/userRepository');
const { sequelize } = require('../config/database');
const initModels = require('../models/init-models');

const models = initModels(sequelize);

class WorkerApplicationService {
    // Tạo đơn đăng ký worker
    async createApplication(userId, applicationData, files) {
        try {
            // Kiểm tra user có tồn tại và là customer không
            const user = await userRepository.findById(userId);
            if (!user) {
                throw new Error('Khong tim thay nguoi dung');
            }

            if (user.role !== 'customer') {
                throw new Error('Chi khach hang moi co the dang ky lam tho');
            }

            // Kiểm tra đã có đơn đăng ký pending chưa
            const hasPending = await workerApplicationRepository.hasPendingApplication(userId);
            if (hasPending) {
                throw new Error('Ban da co don dang ky dang cho xu ly');
            }

            // Xử lý file uploads
            const baseUrl = `${applicationData.protocol}://${applicationData.host}`;

            if (!files.identity_front || !files.identity_back) {
                throw new Error('Can tai len anh CCCD mat truoc va mat sau');
            }

            const identityFrontUrl = `${baseUrl}/uploads/${files.identity_front[0].filename}`;
            const identityBackUrl = `${baseUrl}/uploads/${files.identity_back[0].filename}`;

            // Xử lý chứng chỉ (không bắt buộc)
            let certificateUrls = [];
            if (files.certificates) {
                certificateUrls = files.certificates.map(file => `${baseUrl}/uploads/${file.filename}`);
            }

            // Tạo đơn đăng ký
            const application = await workerApplicationRepository.createApplication({
                user_id: userId,
                citizen_id: applicationData.citizenId,
                bio: applicationData.bio,
                experience_years: applicationData.experienceYears || 0,
                radius_km: applicationData.radiusKm || 10,
                identity_front_url: identityFrontUrl,
                identity_back_url: identityBackUrl,
                certificate_urls: certificateUrls.length > 0 ? certificateUrls : null,
                service_ids: applicationData.serviceIds,
                status: 'pending'
            });

            return application;
        } catch (error) {
            throw new Error(`Khong the tao don dang ky: ${error.message}`);
        }
    }

    // Lấy đơn đăng ký của user
    async getUserApplication(userId) {
        try {
            return await workerApplicationRepository.getApplicationByUserId(userId);
        } catch (error) {
            throw new Error(`Khong the lay don dang ky: ${error.message}`);
        }
    }

    // Lấy tất cả đơn đăng ký (admin)
    async getAllApplications(options) {
        try {
            return await workerApplicationRepository.getAllApplications(options);
        } catch (error) {
            throw new Error(`Khong the lay danh sach don dang ky: ${error.message}`);
        }
    }

    // Lấy chi tiết đơn đăng ký (admin)
    async getApplicationById(applicationId) {
        try {
            const application = await workerApplicationRepository.getApplicationById(applicationId);
            if (!application) {
                throw new Error('Khong tim thay don dang ky');
            }
            return application;
        } catch (error) {
            throw new Error(`Khong the lay chi tiet don dang ky: ${error.message}`);
        }
    }

    // Duyệt đơn đăng ký (admin)
    async approveApplication(applicationId, adminId, adminNote = null) {
        const transaction = await sequelize.transaction();

        try {
            // Lấy thông tin đơn đăng ký
            const application = await workerApplicationRepository.getApplicationById(applicationId);
            if (!application) {
                throw new Error('Khong tim thay don dang ky');
            }

            if (application.status !== 'pending') {
                throw new Error('Don dang ky da duoc xu ly');
            }

            // Cập nhật trạng thái đơn đăng ký
            await workerApplicationRepository.updateApplicationStatus(
                applicationId,
                'approved',
                adminNote,
                adminId
            );

            // Cập nhật role user thành worker
            await models.users.update(
                { role: 'worker' },
                { where: { id: application.user_id } },
                { transaction }
            );

            // Tạo worker profile
            await models.worker_profiles.create({
                user_id: application.user_id,
                citizen_id: application.citizen_id,
                bio: application.bio,
                experience_years: application.experience_years,
                radius_km: application.radius_km,
                is_verified: true
            }, { transaction });

            // Tạo worker attachments
            const attachments = [
                {
                    worker_id: application.user_id,
                    type: 'identity_front',
                    url: application.identity_front_url,
                    verified_at: new Date()
                },
                {
                    worker_id: application.user_id,
                    type: 'identity_back',
                    url: application.identity_back_url,
                    verified_at: new Date()
                }
            ];

            // Thêm chứng chỉ nếu có
            if (application.certificate_urls) {
                application.certificate_urls.forEach(url => {
                    attachments.push({
                        worker_id: application.user_id,
                        type: 'certificate',
                        url: url,
                        verified_at: new Date()
                    });
                });
            }

            await models.worker_attachments.bulkCreate(attachments, { transaction });

            // Tạo worker services
            const workerServices = application.service_ids.map(serviceId => ({
                worker_id: application.user_id,
                service_id: serviceId,
                is_active: true
            }));

            await models.worker_services.bulkCreate(workerServices, { transaction });

            await transaction.commit();

            return await workerApplicationRepository.getApplicationById(applicationId);
        } catch (error) {
            await transaction.rollback();
            throw new Error(`Khong the duyet don dang ky: ${error.message}`);
        }
    }

    // Từ chối đơn đăng ký (admin)
    async rejectApplication(applicationId, adminId, adminNote) {
        try {
            const application = await workerApplicationRepository.getApplicationById(applicationId);
            if (!application) {
                throw new Error('Khong tim thay don dang ky');
            }

            if (application.status !== 'pending') {
                throw new Error('Don dang ky da duoc xu ly');
            }

            await workerApplicationRepository.updateApplicationStatus(
                applicationId,
                'rejected',
                adminNote,
                adminId
            );

            return await workerApplicationRepository.getApplicationById(applicationId);
        } catch (error) {
            throw new Error(`Khong the tu choi don dang ky: ${error.message}`);
        }
    }

    // Lấy thống kê đơn đăng ký
    async getApplicationStats() {
        try {
            return await workerApplicationRepository.getApplicationStats();
        } catch (error) {
            throw new Error(`Khong the lay thong ke: ${error.message}`);
        }
    }

    // Lấy đơn đăng ký theo trạng thái
    async getApplicationsByStatus(status, options) {
        try {
            return await workerApplicationRepository.getApplicationsByStatus(status, options);
        } catch (error) {
            throw new Error(`Khong the lay don dang ky theo trang thai: ${error.message}`);
        }
    }
}

module.exports = new WorkerApplicationService();