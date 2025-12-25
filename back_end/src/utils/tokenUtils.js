/**
 * Tien ich token
 */

const jwt = require('jsonwebtoken');

// Tao token JWT
const generateToken = (payload, secret = process.env.JWT_SECRET || 'fallback_secret_key', expiresIn = '24h') => {
  return jwt.sign(payload, secret, { expiresIn });
};

// Xac minh token JWT
const verifyToken = (token, secret = process.env.JWT_SECRET || 'fallback_secret_key') => {
  try {
    return {
      valid: true,
      decoded: jwt.verify(token, secret)
    };
  } catch (error) {
    return {
      valid: false,
      error: error.name,
      message: error.message
    };
  }
};

// Giai ma token ma khong can xac minh (cho muc dich ghi log)
const decodeToken = (token) => {
  try {
    return {
      valid: true,
      decoded: jwt.decode(token)
    };
  } catch (error) {
    return {
      valid: false,
      error: error.name,
      message: error.message
    };
  }
};

module.exports = {
  generateToken,
  verifyToken,
  decodeToken
};