const { errorResponse } = require('../utils/responseUtils');

// Middleware kiểm tra quyền admin
const requireAdmin = (req, res, next) => {
    try {
        // Kiểm tra xem user đã được authenticate chưa
        if (!req.user) {
            return errorResponse(res, 'Yeu cau xac thuc', 401);
        }

        // Kiểm tra role admin
        if (req.user.role !== 'admin') {
            return errorResponse(res, 'Khong co quyen truy cap. Chi admin moi duoc phep.', 403);
        }

        next();
    } catch (error) {
        console.error('Loi middleware admin:', error);
        return errorResponse(res, 'Loi he thong');
    }
};

// Middleware kiểm tra quyền admin hoặc chính user đó
const requireAdminOrSelf = (req, res, next) => {
    try {
        if (!req.user) {
            return errorResponse(res, 'Yeu cau xac thuc', 401);
        }

        const { userId } = req.params;
        const currentUserId = req.user.id;
        const userRole = req.user.role;

        // Cho phép nếu là admin hoặc chính user đó
        if (userRole === 'admin' || currentUserId.toString() === userId.toString()) {
            next();
        } else {
            return errorResponse(res, 'Khong co quyen truy cap', 403);
        }
    } catch (error) {
        console.error('Loi middleware admin or self:', error);
        return errorResponse(res, 'Loi he thong');
    }
};

// Middleware kiểm tra quyền super admin (có thể mở rộng sau)
const requireSuperAdmin = (req, res, next) => {
    try {
        if (!req.user) {
            return errorResponse(res, 'Yeu cau xac thuc', 401);
        }

        // Hiện tại chỉ kiểm tra admin, có thể mở rộng thêm super_admin role
        if (req.user.role !== 'admin') {
            return errorResponse(res, 'Khong co quyen truy cap. Chi super admin moi duoc phep.', 403);
        }

        next();
    } catch (error) {
        console.error('Loi middleware super admin:', error);
        return errorResponse(res, 'Loi he thong');
    }
};

module.exports = {
    requireAdmin,
    requireAdminOrSelf,
    requireSuperAdmin
};