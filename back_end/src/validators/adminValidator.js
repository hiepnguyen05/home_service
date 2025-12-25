const { body, param, query, validationResult } = require('express-validator');
const { validationErrorResponse } = require('../utils/responseUtils');

// Validation cho cập nhật user
const updateUserValidation = [
    body('fullName')
        .optional()
        .isLength({ min: 2 })
        .withMessage('Ho ten phai co it nhat 2 ky tu'),
    body('email')
        .optional()
        .isEmail()
        .withMessage('Email khong hop le'),
    body('phone')
        .optional()
        .isNumeric()
        .isLength({ min: 10, max: 10 })
        .withMessage('So dien thoai phai dung 10 chu so'),
    body('password')
        .optional()
        .isLength({ min: 8 })
        .withMessage('Mat khau phai co it nhat 8 ky tu')
        .matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]/)
        .withMessage('Mat khau phai chua it nhat mot chu cai va mot chu so')
];

// Validation cho cập nhật status
const updateStatusValidation = [
    body('status')
        .notEmpty()
        .withMessage('Trang thai la bat buoc')
        .isIn(['active', 'inactive', 'banned', 'pending_verification'])
        .withMessage('Trang thai khong hop le')
];

// Validation cho cập nhật role
const updateRoleValidation = [
    body('role')
        .notEmpty()
        .withMessage('Role la bat buoc')
        .isIn(['customer', 'worker', 'admin'])
        .withMessage('Role khong hop le')
];

// Validation cho tạo admin
const createAdminValidation = [
    body('fullName')
        .notEmpty()
        .withMessage('Ho ten la bat buoc')
        .isLength({ min: 2 })
        .withMessage('Ho ten phai co it nhat 2 ky tu'),
    body('phone')
        .notEmpty()
        .withMessage('So dien thoai la bat buoc')
        .isNumeric()
        .withMessage('So dien thoai chi duoc chua chu so')
        .isLength({ min: 10, max: 10 })
        .withMessage('So dien thoai phai dung 10 chu so'),
    body('email')
        .notEmpty()
        .withMessage('Email la bat buoc')
        .isEmail()
        .withMessage('Vui long cung cap dia chi email hop le'),
    body('password')
        .notEmpty()
        .withMessage('Mat khau la bat buoc')
        .isLength({ min: 8 })
        .withMessage('Mat khau phai co it nhat 8 ky tu')
        .matches(/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]/)
        .withMessage('Mat khau phai chua it nhat mot chu cai va mot chu so')
];

// Validation cho ban user
const banUserValidation = [
    body('reason')
        .optional()
        .isLength({ max: 500 })
        .withMessage('Ly do ban khong duoc qua 500 ky tu')
];

// Validation cho userId param
const userIdValidation = [
    param('userId')
        .notEmpty()
        .withMessage('User ID la bat buoc')
        .isNumeric()
        .withMessage('User ID phai la so')
];

// Validation cho query parameters
const queryValidation = [
    query('page')
        .optional()
        .isInt({ min: 1 })
        .withMessage('Page phai la so nguyen duong'),
    query('limit')
        .optional()
        .isInt({ min: 1, max: 100 })
        .withMessage('Limit phai la so nguyen tu 1 den 100'),
    query('role')
        .optional()
        .isIn(['customer', 'worker', 'admin'])
        .withMessage('Role khong hop le'),
    query('status')
        .optional()
        .isIn(['active', 'inactive', 'banned', 'pending_verification'])
        .withMessage('Status khong hop le'),
    query('sortBy')
        .optional()
        .isIn(['createdAt', 'updatedAt', 'full_name', 'email', 'phone'])
        .withMessage('SortBy khong hop le'),
    query('sortOrder')
        .optional()
        .isIn(['ASC', 'DESC'])
        .withMessage('SortOrder phai la ASC hoac DESC')
];

// Validation cho advanced search
const advancedSearchValidation = [
    query('fullName')
        .optional()
        .isLength({ min: 1 })
        .withMessage('Ten tim kiem phai co it nhat 1 ky tu'),
    query('email')
        .optional()
        .isEmail()
        .withMessage('Email khong hop le'),
    query('phone')
        .optional()
        .isNumeric()
        .withMessage('So dien thoai chi duoc chua chu so'),
    query('createdFrom')
        .optional()
        .isISO8601()
        .withMessage('Ngay bat dau khong hop le'),
    query('createdTo')
        .optional()
        .isISO8601()
        .withMessage('Ngay ket thuc khong hop le')
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
    updateUserValidation,
    updateStatusValidation,
    updateRoleValidation,
    createAdminValidation,
    banUserValidation,
    userIdValidation,
    queryValidation,
    advancedSearchValidation,
    handleValidationErrors
};