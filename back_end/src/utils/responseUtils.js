/**
 * Tien ich phan hoi tieu chuan
 */

// Phan hoi thanh cong
const successResponse = (res, data, message = 'Thanh cong', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    ...data
  });
};

// Phan hoi loi
const errorResponse = (res, message = 'Loi he thong', statusCode = 500, errors = null) => {
  const response = {
    success: false,
    message
  };

  if (errors) {
    response.errors = errors;
  }

  if (process.env.NODE_ENV === 'development' && statusCode === 500) {
    response.error = message;
  }

  return res.status(statusCode).json(response);
};

// Phan hoi loi validation
const validationErrorResponse = (res, errors) => {
  return res.status(400).json({
    success: false,
    message: 'Du lieu dau vao khong hop le',
    errors: errors.array()
  });
};

// Phan hoi khong tim thay
const notFoundResponse = (res, message = 'Khong tim thay tai nguyen') => {
  return res.status(404).json({
    success: false,
    message
  });
};

// Phan hoi khong duoc uyen quyen
const unauthorizedResponse = (res, message = 'Khong duoc uyen quyen truy cap') => {
  return res.status(401).json({
    success: false,
    message
  });
};

// Phan hoi cam truy cap
const forbiddenResponse = (res, message = 'Cam truy cap') => {
  return res.status(403).json({
    success: false,
    message
  });
};

module.exports = {
  successResponse,
  errorResponse,
  validationErrorResponse,
  notFoundResponse,
  unauthorizedResponse,
  forbiddenResponse
};