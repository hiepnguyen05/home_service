const responseUtils = require('../utils/responseUtils');

/**
 * 404 Not Found handler middleware
 * Xử lý các route không tồn tại
 */
const notFoundHandler = (req, res, next) => {
    const message = `Route ${req.originalUrl} không tồn tại trên server này`;

    responseUtils.error(res, message, 404, {
        method: req.method,
        url: req.originalUrl,
        timestamp: new Date().toISOString()
    });
};

module.exports = notFoundHandler;