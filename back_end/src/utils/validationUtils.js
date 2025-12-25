/**
 * Tien ich validation
 */

// Kiem tra dinh dang so dien thoai (chinh xac 10 chu so)
const isValidPhoneNumber = (phone) => {
  const phoneRegex = /^\d{10}$/;
  return phoneRegex.test(phone);
};

// Kiem tra do manh mat khau
const isValidPassword = (password) => {
  // It nhat 8 ky tu, chua ca chu cai va so
  const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$/;
  return passwordRegex.test(password);
};

// Kiem tra dinh dang email
const isValidEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

module.exports = {
  isValidPhoneNumber,
  isValidPassword,
  isValidEmail
};