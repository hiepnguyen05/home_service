const { body, validationResult } = require('express-validator');
const { validationErrorResponse } = require('../utils/responseUtils');

// Middleware validation cho dang ky
const registerValidation = [
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

// Middleware validation cho dang nhap
const loginValidation = [
  body('identifier')
    .notEmpty()
    .withMessage('Email hoac so dien thoai la bat buoc'),
  body('password')
    .notEmpty()
    .withMessage('Mat khau la bat buoc')
];

// Middleware validation cho cap nhat ho so
const profileUpdateValidation = [
  body('fullName')
    .optional()
    .isLength({ min: 2 })
    .withMessage('Ho ten phai co it nhat 2 ky tu'),
  body('avatarUrl')
    .optional()
    .isURL()
    .withMessage('URL anh dai dien phai hop le')
];

// Middleware validation cho cap nhat dia chi
const addressUpdateValidation = [
  body('name')
    .optional()
    .isLength({ max: 50 })
    .withMessage('Ten dia chi phai it hon 50 ky tu'),
  body('address')
    .notEmpty()
    .withMessage('Dia chi la bat buoc')
    .isLength({ max: 255 })
    .withMessage('Dia chi phai it hon 255 ky tu'),
  body('latitude')
    .notEmpty()
    .withMessage('Vi do la bat buoc')
    .isFloat({ min: -90, max: 90 })
    .withMessage('Vi do phai nam trong khoang -90 den 90'),
  body('longitude')
    .notEmpty()
    .withMessage('Kinh do la bat buoc')
    .isFloat({ min: -180, max: 180 })
    .withMessage('Kinh do phai nam trong khoang -180 den 180'),
  body('isDefault')
    .optional()
    .isBoolean()
    .withMessage('isDefault phai la gia tri boolean')
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
  registerValidation,
  loginValidation,
  profileUpdateValidation,
  addressUpdateValidation,
  handleValidationErrors
};