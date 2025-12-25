const userService = require('../services/userService');
const { successResponse, errorResponse, validationErrorResponse } = require('../utils/responseUtils');
const { validationResult } = require('express-validator');

// Cap nhat thong tin ca nhan va anh dai dien cua nguoi dung
const updateUserProfile = async (req, res) => {
  try {
    // Xac thuc du lieu dau vao truoc khi cap nhat
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return validationErrorResponse(res, errors);
    }

    const { fullName, avatarUrl } = req.body;
    const userId = req.user.id;

    // Xay dung doi tuong du lieu can cap nhat
    const profileData = {};
    if (fullName !== undefined) profileData.full_name = fullName;
    
    // Xu ly tai len anh dai dien neu co file dinh kem
    if (req.file) {
      // Tao duong dan day du den file da tai len
      const baseUrl = `${req.protocol}://${req.get('host')}`;
      profileData.avatar_url = `${baseUrl}/uploads/${req.file.filename}`;
    } else if (avatarUrl !== undefined) {
      // Su dung URL anh dai dien duoc cung cap
      profileData.avatar_url = avatarUrl;
    }

    // Thuc hien cap nhat thong tin qua tang service
    const updatedUser = await userService.updateUserProfile(userId, profileData);

    // Tao doi tuong phan hoi chuan
    const userResponse = {
      user: {
        id: updatedUser.id,
        code: updatedUser.code,
        full_name: updatedUser.full_name,
        phone: updatedUser.phone,
        email: updatedUser.email,
        avatar_url: updatedUser.avatar_url,
        role: updatedUser.role,
        status: updatedUser.status,
        created_at: updatedUser.created_at,
        updated_at: updatedUser.updated_at
      }
    };

    return successResponse(res, userResponse, 'Cap nhat thong tin ca nhan thanh cong');

  } catch (error) {
    console.error('Loi cap nhat thong tin ca nhan:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

// Cap nhat hoac tao dia chi mac dinh cho nguoi dung
const updateUserAddress = async (req, res) => {
  try {
    // Xac thuc du lieu dia chi truoc khi cap nhat
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return validationErrorResponse(res, errors);
    }

    const { name, address, latitude, longitude, isDefault } = req.body;
    const userId = req.user.id;

    // Xay dung doi tuong du lieu dia chi can cap nhat
    const addressData = {};
    if (name !== undefined) addressData.name = name;
    if (address !== undefined) addressData.address = address;
    if (latitude !== undefined) addressData.latitude = latitude;
    if (longitude !== undefined) addressData.longitude = longitude;
    if (isDefault !== undefined) addressData.is_default = isDefault;

    // Thuc hien cap nhat dia chi qua tang service
    const savedAddress = await userService.updateUserAddress(userId, addressData);

    // Tao doi tuong phan hoi chuan
    const addressResponse = {
      address: {
        id: savedAddress.id,
        name: savedAddress.name,
        address: savedAddress.address,
        latitude: savedAddress.latitude,
        longitude: savedAddress.longitude,
        is_default: savedAddress.is_default,
        created_at: savedAddress.created_at,
        updated_at: savedAddress.updated_at
      }
    };

    return successResponse(res, addressResponse, 'Cap nhat dia chi thanh cong');

  } catch (error) {
    console.error('Loi cap nhat dia chi:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

// Truy xuat thong tin ca nhan va danh sach dia chi cua nguoi dung
const getUserProfileWithAddresses = async (req, res) => {
  try {
    const userId = req.user.id;

    // Lay thong tin ca nhan va dia chi thong qua tang service
    const { user, addresses } = await userService.getUserProfileWithAddresses(userId);

    // Tao doi tuong phan hoi chuan
    const profileResponse = {
      user: {
        id: user.id,
        code: user.code,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email,
        avatar_url: user.avatar_url,
        role: user.role,
        status: user.status,
        created_at: user.created_at,
        updated_at: user.updated_at
      },
      addresses: addresses.map(address => ({
        id: address.id,
        name: address.name,
        address: address.address,
        latitude: address.latitude,
        longitude: address.longitude,
        is_default: address.is_default,
        created_at: address.created_at,
        updated_at: address.updated_at
      }))
    };

    return successResponse(res, profileResponse, 'Lay thong tin ca nhan thanh cong');

  } catch (error) {
    console.error('Loi lay thong tin ca nhan:', error);
    return errorResponse(res, 'Loi he thong');
  }
};

module.exports = {
  updateUserProfile,
  updateUserAddress,
  getUserProfileWithAddresses
};