const express = require('express');
const adminController = require('../controllers/adminController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { requireAdmin, requireSuperAdmin } = require('../middleware/adminMiddleware');
const {
    updateUserValidation,
    updateStatusValidation,
    updateRoleValidation,
    createAdminValidation,
    banUserValidation,
    userIdValidation,
    queryValidation,
    advancedSearchValidation,
    handleValidationErrors
} = require('../validators/adminValidator');

const router = express.Router();

// Tất cả routes đều yêu cầu authentication và admin role
router.use(authenticateToken);
router.use(requireAdmin);

// === USER MANAGEMENT ROUTES ===

// Lấy danh sách tất cả người dùng
router.get('/users',
    queryValidation,
    handleValidationErrors,
    adminController.getAllUsers
);

// Lấy danh sách chỉ customers
router.get('/users/customers',
    queryValidation,
    handleValidationErrors,
    adminController.getCustomers
);

// Lấy danh sách chỉ workers
router.get('/users/workers',
    queryValidation,
    handleValidationErrors,
    adminController.getWorkers
);

// Lấy danh sách chỉ admins
router.get('/users/admins',
    queryValidation,
    handleValidationErrors,
    adminController.getAdmins
);

// === STATUS FILTER ROUTES ===

// Lấy danh sách users active
router.get('/users/status/active',
    queryValidation,
    handleValidationErrors,
    (req, res, next) => {
        req.query.status = 'active';
        next();
    },
    adminController.getAllUsers
);

// Lấy danh sách users banned
router.get('/users/status/banned',
    queryValidation,
    handleValidationErrors,
    (req, res, next) => {
        req.query.status = 'banned';
        next();
    },
    adminController.getAllUsers
);

// Lấy danh sách users inactive
router.get('/users/status/inactive',
    queryValidation,
    handleValidationErrors,
    (req, res, next) => {
        req.query.status = 'inactive';
        next();
    },
    adminController.getAllUsers
);

// Lấy danh sách users pending verification
router.get('/users/status/pending',
    queryValidation,
    handleValidationErrors,
    (req, res, next) => {
        req.query.status = 'pending_verification';
        next();
    },
    adminController.getAllUsers
);

// Lấy thông tin chi tiết một người dùng
router.get('/users/:userId',
    userIdValidation,
    handleValidationErrors,
    adminController.getUserById
);

// Cập nhật thông tin người dùng
router.put('/users/:userId',
    userIdValidation,
    updateUserValidation,
    handleValidationErrors,
    adminController.updateUser
);

// Cập nhật trạng thái người dùng
router.patch('/users/:userId/status',
    userIdValidation,
    updateStatusValidation,
    handleValidationErrors,
    adminController.updateUserStatus
);

// Cập nhật role người dùng
router.patch('/users/:userId/role',
    userIdValidation,
    updateRoleValidation,
    handleValidationErrors,
    adminController.updateUserRole
);

// Ban người dùng
router.patch('/users/:userId/ban',
    userIdValidation,
    banUserValidation,
    handleValidationErrors,
    adminController.banUser
);

// Unban người dùng
router.patch('/users/:userId/unban',
    userIdValidation,
    handleValidationErrors,
    adminController.unbanUser
);

// Xóa mềm người dùng
router.delete('/users/:userId',
    userIdValidation,
    handleValidationErrors,
    adminController.deleteUser
);

// Khôi phục người dùng đã xóa
router.patch('/users/:userId/restore',
    userIdValidation,
    handleValidationErrors,
    adminController.restoreUser
);

// Xóa cứng người dùng (chỉ super admin)
router.delete('/users/:userId/permanent',
    requireSuperAdmin,
    userIdValidation,
    handleValidationErrors,
    adminController.permanentDeleteUser
);

// === STATISTICS ROUTES ===

// Lấy thống kê người dùng
router.get('/stats/users', adminController.getUserStats);

// === SEARCH ROUTES ===

// Tìm kiếm nâng cao
router.get('/search/users',
    advancedSearchValidation,
    handleValidationErrors,
    adminController.advancedSearch
);

// Lấy danh sách người dùng đã xóa
router.get('/users/deleted/list',
    queryValidation,
    handleValidationErrors,
    adminController.getDeletedUsers
);

// === ADMIN MANAGEMENT ROUTES ===

// Tạo tài khoản admin mới (chỉ super admin)
router.post('/admins',
    requireSuperAdmin,
    createAdminValidation,
    handleValidationErrors,
    adminController.createAdmin
);

module.exports = router;