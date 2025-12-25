const express = require('express');
const authController = require('../controllers/authController');
const { registerValidation, loginValidation, handleValidationErrors } = require('../validators/authValidator');

const router = express.Router();

// Tuyến đường
router.post('/register', registerValidation, handleValidationErrors, authController.registerUser);
router.post('/login', loginValidation, handleValidationErrors, authController.loginUser);

module.exports = router;