const express = require('express');
const workerApplicationController = require('../controllers/workerApplicationController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { requireAdmin } = require('../middleware/adminMiddleware');
const { uploadWorkerFiles, handleUploadError } = require('../utils/uploadUtils');
const {
    createApplicationValidation,
    reviewApplicationValidation,
    rejectApplicationValidation,
    applicationIdValidation,
    handleValidationErrors
} = require('../validators/workerApplicationValidator');

const router = express.Router();

// Tất cả routes đều yêu cầu authentication
router.use(authenticateToken);

// === CUSTOMER ROUTES ===

// Tạo đơn đăng ký worker
router.post('/apply',
    uploadWorkerFiles,
    handleUploadError,
    createApplicationValidation,
    handleValidationErrors,
    workerApplicationController.createApplication
);

// Lấy đơn đăng ký của user hiện tại
router.get('/my-application',
    workerApplicationController.getMyApplication
);

// === ADMIN ROUTES ===

// Lấy tất cả đơn đăng ký
router.get('/',
    requireAdmin,
    workerApplicationController.getAllApplications
);

// Lấy thống kê đơn đăng ký
router.get('/stats',
    requireAdmin,
    workerApplicationController.getApplicationStats
);

// Lấy đơn đăng ký pending
router.get('/pending',
    requireAdmin,
    workerApplicationController.getPendingApplications
);

// Lấy đơn đăng ký đã duyệt
router.get('/approved',
    requireAdmin,
    workerApplicationController.getApprovedApplications
);

// Lấy đơn đăng ký bị từ chối
router.get('/rejected',
    requireAdmin,
    workerApplicationController.getRejectedApplications
);

// Lấy chi tiết đơn đăng ký
router.get('/:applicationId',
    requireAdmin,
    applicationIdValidation,
    handleValidationErrors,
    workerApplicationController.getApplicationById
);

// Duyệt đơn đăng ký
router.patch('/:applicationId/approve',
    requireAdmin,
    applicationIdValidation,
    reviewApplicationValidation,
    handleValidationErrors,
    workerApplicationController.approveApplication
);

// Từ chối đơn đăng ký
router.patch('/:applicationId/reject',
    requireAdmin,
    applicationIdValidation,
    rejectApplicationValidation,
    handleValidationErrors,
    workerApplicationController.rejectApplication
);

module.exports = router;