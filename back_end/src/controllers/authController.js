const authService = require('../services/authService');
const { successResponse, errorResponse, validationErrorResponse } = require('../utils/responseUtils');
const { validationResult } = require('express-validator');

// Xu ly dang ky tai khoan nguoi dung moi voi thong tin day du
const registerUser = async (req, res) => {
  try {
    // Kiem tra va xac thuc du lieu dau vao theo quy dinh
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return validationErrorResponse(res, errors);
    }

    const { fullName, phone, email, password } = req.body;

    // Dam bao tinh duy nhat cua so dien thoai trong he thong
    const existingPhoneUser = await authService.findUserByPhone(phone);

    if (existingPhoneUser) {
      return errorResponse(res, 'So dien thoai da ton tai', 400);
    }

    // Dam bao tinh duy nhat cua dia chi email trong he thong
    const existingEmailUser = await authService.findUserByEmail(email);

    if (existingEmailUser) {
      return errorResponse(res, 'Email da ton tai', 400);
    }

    // Ma hoa mat khau truoc khi luu vao co so du lieu
    const hashedPassword = await authService.hashPassword(password);

    // Tao ban ghi nguoi dung moi trong co so du lieu
    const newUser = await authService.createUser({
      full_name: fullName,
      phone: phone,
      email: email,
      password_hash: hashedPassword,
      role: 'customer', // Vai tro mac dinh cho nguoi dung
      status: 'active'
    });

    // Tao token xac thuc de nguoi dung truy cap he thong
    const token = authService.generateToken(newUser);

    // Tao doi tuong phan hoi khong chua thong tin mat khau
    const userResponse = {
      user: {
        id: newUser.id,
        code: newUser.code,
        full_name: newUser.full_name,
        phone: newUser.phone,
        email: newUser.email,
        role: newUser.role,
        status: newUser.status,
        created_at: newUser.created_at,
        updated_at: newUser.updated_at
      },
      token: token
    };

    return successResponse(res, userResponse, 'Dang ky thanh cong', 201);

  } catch (error) {
    console.error('Loi dang ky:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

// Xac thuc dang nhap nguoi dung bang email hoac so dien thoai
const loginUser = async (req, res) => {
  try {
    const { identifier, password } = req.body;

    // Kiem tra tinh hop le cua thong tin dang nhap
    if (!identifier || !password) {
      return errorResponse(res, 'Vui long cung cap email/so dien thoai va mat khau', 400);
    }

    // Tim kiem nguoi dung theo email hoac so dien thoai
    const user = await authService.findUserByIdentifier(identifier);

    if (!user) {
      return errorResponse(res, 'Thong tin dang nhap khong chinh xac', 401);
    }

    // Kiem tra tinh hop le cua mat khau
    const isPasswordValid = await authService.comparePassword(password, user.password_hash);
    if (!isPasswordValid) {
      return errorResponse(res, 'Thong tin dang nhap khong chinh xac', 401);
    }

    // Tao token xac thuc moi cho phien dang nhap
    const token = authService.generateToken(user);

    // Tao doi tuong phan hoi khong chua thong tin mat khau
    const userResponse = {
      user: {
        id: user.id,
        code: user.code,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        status: user.status,
        created_at: user.created_at,
        updated_at: user.updated_at
      },
      token: token
    };

    return successResponse(res, userResponse, 'Dang nhap thanh cong');

  } catch (error) {
    console.error('Loi dang nhap:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

module.exports = {
  registerUser,
  loginUser
};