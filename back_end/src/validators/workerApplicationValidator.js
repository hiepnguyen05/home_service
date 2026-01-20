const { body, param, validationResult } = require('express-validator');
const { validationErrorResponse } = require('../utils/responseUtils');

// Validation cho tạo đơn đăng ký
const createApplicationValidation = [
    body('citizenId')
        .notEmpty()
        .withMessage('So CCCD la bat buoc')
        .isLength({ min: 9, max: 12 })
        .withMessage('So CCCD phai tu 9-12 chu so')
        .isNumeric()
        .withMessage('So CCCD chi duoc chua chu so'),

    body('bio')
        .optional()
        .isLength({ max: 1000 })
        .withMessage('Gioi thieu ban than khong duoc qua 1000 ky tu'),

    body('experienceYears')
        .optional()
        .isInt({ min: 0, max: 50 })
        .withMessage('So nam kinh nghiem phai tu 0-50'),

    body('radiusKm')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Ban kinh hoat dong phai tu 1-100 km'),

    body('serviceIds')
        .notEmpty()
        .withMessage('Phai chon it nhat mot dich vu')
        .isArray({ min: 1 })
        .withMessage('Danh sach dich vu phai la mang va co it nhat 1 phan tu'),

    body('serviceIds.*')
        .isInt({ min: 1 })
        .withMessage('ID dich vu phai la so nguyen duong')
];

// Validation cho duyệt/từ chối đơn
const reviewApplicationValidation = [
    body('adminNote')
        .optional()
        .isLength({ max: 500 })
        .withMessage('Ghi chu admin khong duoc qua 500 ky tu')
];

// Validation cho từ chối đơn (bắt buộc có lý do)
const rejectApplicationValidation = [
    body('adminNote')
        .notEmpty()
        .withMessage('Ly do tu choi la bat buoc')
        .isLength({ min: 10, max: 500 })
        .withMessage('Ly do tu choi phai tu 10-500 ky tu')
];

// Validation cho applicationId param
const applicationIdValidation = [
    param('applicationId')
        .notEmpty()
        .withMessage('Application ID la bat buoc')
        .isInt({ min: 1 })
        .withMessage('Application ID phai la so nguyen duong')
];

// Xu ly ket qua validation
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return validationErrorResponse(res, errors);
    }
    next();
};

module.exports = {
    createApplicationValidation,
    reviewApplicationValidation,
    rejectApplicationValidation,
    applicationIdValidation,
    handleValidationErrors
};