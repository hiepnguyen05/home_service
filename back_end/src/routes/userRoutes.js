const express = require('express');
const userController = require('../controllers/userController');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Các tuyến đường được bảo vệ
router.get('/profile', authenticateToken, userController.getUserProfile);
router.post('/logout', authenticateToken, userController.logoutUser);

module.exports = router;