const workerApplicationService = require('../services/workerApplicationService');
const { successResponse, errorResponse, validationErrorResponse } = require('../utils/responseUtils');
const { validationResult } = require('express-validator');

// Tạo đơn đăng ký worker (customer)
const createApplication = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const userId = req.user.id;
        const applicationData = {
            ...req.body,
            protocol: req.protocol,
            host: req.get('host')
        };

        const application = await workerApplicationService.createApplication(
            userId,
            applicationData,
            req.files
        );

        return successResponse(res, { application }, 'Tao don dang ky thanh cong', 201);

    } catch (error) {
        console.error('Loi tao don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy đơn đăng ký của user hiện tại (customer)
const getMyApplication = async (req, res) => {
    try {
        const userId = req.user.id;
        const application = await workerApplicationService.getUserApplication(userId);

        if (!application) {
            return errorResponse(res, 'Khong tim thay don dang ky', 404);
        }

        return successResponse(res, { application }, 'Lay don dang ky thanh cong');

    } catch (error) {
        console.error('Loi lay don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy tất cả đơn đăng ký (admin)
const getAllApplications = async (req, res) => {
    try {
        const options = {
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 10,
            status: req.query.status,
            sortBy: req.query.sortBy || 'createdAt',
            sortOrder: req.query.sortOrder || 'DESC'
        };

        const result = await workerApplicationService.getAllApplications(options);

        return successResponse(res, result, 'Lay danh sach don dang ky thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy chi tiết đơn đăng ký (admin)
const getApplicationById = async (req, res) => {
    try {
        const { applicationId } = req.params;
        const application = await workerApplicationService.getApplicationById(applicationId);

        return successResponse(res, { application }, 'Lay chi tiet don dang ky thanh cong');

    } catch (error) {
        console.error('Loi lay chi tiet don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Duyệt đơn đăng ký (admin)
const approveApplication = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const { applicationId } = req.params;
        const { adminNote } = req.body;
        const adminId = req.user.id;

        const application = await workerApplicationService.approveApplication(
            applicationId,
            adminId,
            adminNote
        );

        return successResponse(res, { application }, 'Duyet don dang ky thanh cong');

    } catch (error) {
        console.error('Loi duyet don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Từ chối đơn đăng ký (admin)
const rejectApplication = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const { applicationId } = req.params;
        const { adminNote } = req.body;
        const adminId = req.user.id;

        if (!adminNote) {
            return errorResponse(res, 'Ly do tu choi la bat buoc', 400);
        }

        const application = await workerApplicationService.rejectApplication(
            applicationId,
            adminId,
            adminNote
        );

        return successResponse(res, { application }, 'Tu choi don dang ky thanh cong');

    } catch (error) {
        console.error('Loi tu choi don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy thống kê đơn đăng ký (admin)
const getApplicationStats = async (req, res) => {
    try {
        const stats = await workerApplicationService.getApplicationStats();

        return successResponse(res, { stats }, 'Lay thong ke don dang ky thanh cong');

    } catch (error) {
        console.error('Loi lay thong ke don dang ky:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy đơn đăng ký pending (admin)
const getPendingApplications = async (req, res) => {
    try {
        const options = {
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 10,
            sortBy: req.query.sortBy || 'createdAt',
            sortOrder: req.query.sortOrder || 'ASC'
        };

        const result = await workerApplicationService.getApplicationsByStatus('pending', options);

        return successResponse(res, result, 'Lay danh sach don dang ky cho duyet thanh cong');

    } catch (error) {
        console.error('Loi lay don dang ky pending:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy đơn đăng ký đã duyệt (admin)
const getApprovedApplications = async (req, res) => {
    try {
        const options = {
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 10,
            sortBy: req.query.sortBy || 'reviewed_at',
            sortOrder: req.query.sortOrder || 'DESC'
        };

        const result = await workerApplicationService.getApplicationsByStatus('approved', options);

        return successResponse(res, result, 'Lay danh sach don dang ky da duyet thanh cong');

    } catch (error) {
        console.error('Loi lay don dang ky approved:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy đơn đăng ký bị từ chối (admin)
const getRejectedApplications = async (req, res) => {
    try {
        const options = {
            page: parseInt(req.query.page) || 1,
            limit: parseInt(req.query.limit) || 10,
            sortBy: req.query.sortBy || 'reviewed_at',
            sortOrder: req.query.sortOrder || 'DESC'
        };

        const result = await workerApplicationService.getApplicationsByStatus('rejected', options);

        return successResponse(res, result, 'Lay danh sach don dang ky bi tu choi thanh cong');

    } catch (error) {
        console.error('Loi lay don dang ky rejected:', error);
        return errorResponse(res, error.message);
    }
};

module.exports = {
    createApplication,
    getMyApplication,
    getAllApplications,
    getApplicationById,
    approveApplication,
    rejectApplication,
    getApplicationStats,
    getPendingApplications,
    getApprovedApplications,
    getRejectedApplications
};