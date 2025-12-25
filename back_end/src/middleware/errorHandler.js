const responseUtils = require('../utils/responseUtils');

/**
 * Global error handler middleware
 * Xử lý tất cả các lỗi trong ứng dụng
 */
const errorHandler = (err, req, res, next) => {
    let error = { ...err };
    error.message = err.message;

    // Log lỗi để debug
    console.error('Error:', err);

    // Sequelize validation error
    if (err.name === 'SequelizeValidationError') {
        const message = err.errors.map(error => error.message).join(', ');
        return responseUtils.error(res, message, 400);
    }

    // Sequelize unique constraint error
    if (err.name === 'SequelizeUniqueConstraintError') {
        const message = 'Dữ liệu đã tồn tại trong hệ thống';
        return responseUtils.error(res, message, 409);
    }

    // Sequelize foreign key constraint error
    if (err.name === 'SequelizeForeignKeyConstraintError') {
        const message = 'Dữ liệu tham chiếu không hợp lệ';
        return responseUtils.error(res, message, 400);
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        const message = 'Token không hợp lệ';
        return responseUtils.error(res, message, 401);
    }

    if (err.name === 'TokenExpiredError') {
        const message = 'Token đã hết hạn';
        return responseUtils.error(res, message, 401);
    }

    // Multer errors (file upload)
    if (err.code === 'LIMIT_FILE_SIZE') {
        const message = 'File quá lớn. Kích thước tối đa cho phép là 10MB';
        return responseUtils.error(res, message, 400);
    }

    if (err.code === 'LIMIT_FILE_COUNT') {
        const message = 'Quá nhiều file được upload';
        return responseUtils.error(res, message, 400);
    }

    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
        const message = 'Trường file không được hỗ trợ';
        return responseUtils.error(res, message, 400);
    }

    // Validation errors
    if (err.name === 'ValidationError') {
        const message = err.message || 'Dữ liệu đầu vào không hợp lệ';
        return responseUtils.error(res, message, 400);
    }

    // Cast errors (MongoDB ObjectId, etc.)
    if (err.name === 'CastError') {
        const message = 'ID không hợp lệ';
        return responseUtils.error(res, message, 400);
    }

    // Rate limit errors
    if (err.status === 429) {
        const message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
        return responseUtils.error(res, message, 429);
    }

    // Default error
    const statusCode = error.statusCode || error.status || 500;
    const message = error.message || 'Lỗi máy chủ nội bộ';

    // Không trả về stack trace trong production
    const response = {
        success: false,
        message: message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    };

    res.status(statusCode).json(response);
};

module.exports = errorHandler;