const adminService = require('../services/adminService');
const { successResponse, errorResponse, validationErrorResponse } = require('../utils/responseUtils');
const { validationResult } = require('express-validator');

// Lấy danh sách tất cả người dùng
const getAllUsers = async (req, res) => {
    try {
        const {
            page = 1,
            limit = 10,
            role,
            status,
            search,
            sortBy = 'createdAt',
            sortOrder = 'DESC'
        } = req.query;

        const options = {
            page: parseInt(page),
            limit: parseInt(limit),
            role,
            status,
            search,
            sortBy,
            sortOrder
        };

        const result = await adminService.getAllUsers(options);
        return successResponse(res, result, 'Lay danh sach nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy thông tin chi tiết một người dùng
const getUserById = async (req, res) => {
    try {
        const { userId } = req.params;
        const user = await adminService.getUserById(userId);

        return successResponse(res, { user }, 'Lay thong tin nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi lay thong tin nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Cập nhật thông tin người dùng
const updateUser = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const { userId } = req.params;
        const updateData = req.body;

        const updatedUser = await adminService.updateUser(userId, updateData);

        return successResponse(res, { user: updatedUser }, 'Cap nhat nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi cap nhat nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Cập nhật trạng thái người dùng
const updateUserStatus = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const { userId } = req.params;
        const { status } = req.body;

        const updatedUser = await adminService.updateUserStatus(userId, status);

        return successResponse(res, { user: updatedUser }, 'Cap nhat trang thai thanh cong');

    } catch (error) {
        console.error('Loi cap nhat trang thai:', error);
        return errorResponse(res, error.message);
    }
};

// Cập nhật role người dùng
const updateUserRole = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const { userId } = req.params;
        const { role } = req.body;

        const updatedUser = await adminService.updateUserRole(userId, role);

        return successResponse(res, { user: updatedUser }, 'Cap nhat role thanh cong');

    } catch (error) {
        console.error('Loi cap nhat role:', error);
        return errorResponse(res, error.message);
    }
};

// Ban người dùng
const banUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const { reason } = req.body;

        const updatedUser = await adminService.banUser(userId, reason);

        return successResponse(res, { user: updatedUser }, 'Ban nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi ban nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Unban người dùng
const unbanUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const updatedUser = await adminService.unbanUser(userId);

        return successResponse(res, { user: updatedUser }, 'Unban nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi unban nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Xóa mềm người dùng
const deleteUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await adminService.deleteUser(userId);

        return successResponse(res, result, 'Xoa nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi xoa nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Khôi phục người dùng
const restoreUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const restoredUser = await adminService.restoreUser(userId);

        return successResponse(res, { user: restoredUser }, 'Khoi phuc nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi khoi phuc nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Xóa cứng người dùng
const permanentDeleteUser = async (req, res) => {
    try {
        const { userId } = req.params;

        const result = await adminService.permanentDeleteUser(userId);

        return successResponse(res, result, 'Xoa vinh vien nguoi dung thanh cong');

    } catch (error) {
        console.error('Loi xoa vinh vien nguoi dung:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy thống kê người dùng
const getUserStats = async (req, res) => {
    try {
        const stats = await adminService.getUserStats();

        return successResponse(res, { stats }, 'Lay thong ke thanh cong');

    } catch (error) {
        console.error('Loi lay thong ke:', error);
        return errorResponse(res, error.message);
    }
};

// Tạo tài khoản admin mới
const createAdmin = async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return validationErrorResponse(res, errors);
        }

        const adminData = req.body;
        const newAdmin = await adminService.createAdmin(adminData);

        return successResponse(res, { admin: newAdmin }, 'Tao admin thanh cong', 201);

    } catch (error) {
        console.error('Loi tao admin:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy danh sách người dùng đã xóa
const getDeletedUsers = async (req, res) => {
    try {
        const { page = 1, limit = 10 } = req.query;

        const options = {
            page: parseInt(page),
            limit: parseInt(limit)
        };

        const result = await adminService.getDeletedUsers(options);

        return successResponse(res, result, 'Lay danh sach nguoi dung da xoa thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach nguoi dung da xoa:', error);
        return errorResponse(res, error.message);
    }
};

// Tìm kiếm nâng cao
const advancedSearch = async (req, res) => {
    try {
        const searchCriteria = req.query;
        const result = await adminService.advancedSearch(searchCriteria);

        return successResponse(res, result, 'Tim kiem thanh cong');

    } catch (error) {
        console.error('Loi tim kiem:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy danh sách customers
const getCustomers = async (req, res) => {
    try {
        const options = {
            ...req.query,
            role: 'customer'
        };

        const result = await adminService.getAllUsers(options);
        return successResponse(res, result, 'Lay danh sach customers thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach customers:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy danh sách workers
const getWorkers = async (req, res) => {
    try {
        const options = {
            ...req.query,
            role: 'worker'
        };

        const result = await adminService.getAllUsers(options);
        return successResponse(res, result, 'Lay danh sach workers thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach workers:', error);
        return errorResponse(res, error.message);
    }
};

// Lấy danh sách admins
const getAdmins = async (req, res) => {
    try {
        const options = {
            ...req.query,
            role: 'admin'
        };

        const result = await adminService.getAllUsers(options);
        return successResponse(res, result, 'Lay danh sach admins thanh cong');

    } catch (error) {
        console.error('Loi lay danh sach admins:', error);
        return errorResponse(res, error.message);
    }
};

module.exports = {
    getAllUsers,
    getCustomers,
    getWorkers,
    getAdmins,
    getUserById,
    updateUser,
    updateUserStatus,
    updateUserRole,
    banUser,
    unbanUser,
    deleteUser,
    restoreUser,
    permanentDeleteUser,
    getUserStats,
    createAdmin,
    getDeletedUsers,
    advancedSearch
};