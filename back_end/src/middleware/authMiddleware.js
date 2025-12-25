const { verifyToken } = require('../utils/tokenUtils');
const { sequelize } = require('../config/database');
const initModels = require('../models/init-models');
const { unauthorizedResponse, forbiddenResponse, errorResponse } = require('../utils/responseUtils');

const models = initModels(sequelize);

// Middleware bao ve cac duong dan
const authenticateToken = async (req, res, next) => {
  try {
    // Lay token tu header
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return unauthorizedResponse(res, 'Token truy cap la bat buoc');
    }

    // Xac minh token
    const tokenVerification = verifyToken(token);
    
    if (!tokenVerification.valid) {
      if (tokenVerification.error === 'JsonWebTokenError') {
        return forbiddenResponse(res, 'Token khong hop le');
      }
      
      if (tokenVerification.error === 'TokenExpiredError') {
        return forbiddenResponse(res, 'Token da het han');
      }
      
      return forbiddenResponse(res, 'Xac minh token that bai');
    }
    
    const decoded = tokenVerification.decoded;

    // Lay thong tin nguoi dung tu co so du lieu
    const user = await models.users.findByPk(decoded.userId);
    
    if (!user) {
      return unauthorizedResponse(res, 'Token khong hop le: Khong tim thay nguoi dung');
    }

    // Gan thong tin nguoi dung vao doi tuong yeu cau
    req.user = user;
    next();
  } catch (error) {
    console.error('Loi xac thuc:', error);
    return errorResponse(res, 'Loi he thong trong qua trinh xac thuc');
  }
};

module.exports = {
  authenticateToken
};