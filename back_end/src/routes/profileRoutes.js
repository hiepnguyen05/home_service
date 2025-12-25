const express = require('express');
const profileController = require('../controllers/profileController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { profileUpdateValidation, addressUpdateValidation, handleValidationErrors } = require('../validators/authValidator');
const { uploadSingle, handleUploadError } = require('../utils/uploadUtils');

const router = express.Router();

// Tuyến đường hồ sơ (được bảo vệ)
router.put('/update', authenticateToken, uploadSingle, handleUploadError, profileUpdateValidation, handleValidationErrors, profileController.updateUserProfile);
router.put('/address', addressUpdateValidation, handleValidationErrors, authenticateToken, profileController.updateUserAddress);
router.get('/me', authenticateToken, profileController.getUserProfileWithAddresses);

module.exports = router;