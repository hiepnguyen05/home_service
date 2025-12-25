const { successResponse, errorResponse } = require('../utils/responseUtils');

// Lay thong tin ca nhan nguoi dung (duong dan bao ve)
const getUserProfile = async (req, res) => {
  try {
    // Truy xuat thong tin nguoi dung tu doi tuong req da duoc gan boi auth middleware
    const userResponse = {
      user: {
        id: req.user.id,
        code: req.user.code,
        full_name: req.user.full_name,
        phone: req.user.phone,
        email: req.user.email,
        role: req.user.role,
        status: req.user.status,
        created_at: req.user.created_at,
        updated_at: req.user.updated_at
      }
    };

    return successResponse(res, userResponse, 'Lay thong tin ca nhan thanh cong');
  } catch (error) {
    console.error('Loi lay thong tin ca nhan:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

// Ket thuc phien dang nhap cua nguoi dung
const logoutUser = async (req, res) => {
  try {
    // Trong san xuat nen vo hieu hoa token bang cach them vao danh sach den
    // Hien tai chi can phan hoi thanh cong
    
    return successResponse(res, {}, 'Dang xuat thanh cong');
  } catch (error) {
    console.error('Loi dang xuat:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

module.exports = {
  getUserProfile,
  logoutUser
};