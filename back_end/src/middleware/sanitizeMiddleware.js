// Middleware lam sach du lieu dau vao de phong chong XSS
const sanitize = require('sanitize-html');

// Lam sach chuoi ky tu bang cach loai bo cac the HTML nguy hiem
const sanitizeString = (str) => {
  if (typeof str !== 'string') return str;
  
  // Loai bo tat ca cac the HTML va thuoc tinh de dam bao an toan
  return sanitize(str, {
    allowedTags: [], // Khong cho phep bat ky the HTML nao
    allowedAttributes: {}, // Khong cho phep bat ky thuoc tinh nao
  });
};

// Middleware lam sach du lieu trong body cua yeu cau
const sanitizeBody = (req, res, next) => {
  if (req.body && typeof req.body === 'object') {
    for (const key in req.body) {
      if (typeof req.body[key] === 'string') {
        req.body[key] = sanitizeString(req.body[key]);
      }
    }
  }
  
  next();
};

// Middleware lam sach du lieu trong query string
const sanitizeQuery = (req, res, next) => {
  if (req.query && typeof req.query === 'object') {
    for (const key in req.query) {
      if (typeof req.query[key] === 'string') {
        req.query[key] = sanitizeString(req.query[key]);
      }
    }
  }
  
  next();
};

// Middleware lam sach du lieu trong route parameters
const sanitizeParams = (req, res, next) => {
  if (req.params && typeof req.params === 'object') {
    for (const key in req.params) {
      if (typeof req.params[key] === 'string') {
        req.params[key] = sanitizeString(req.params[key]);
      }
    }
  }
  
  next();
};

module.exports = {
  sanitizeBody,
  sanitizeQuery,
  sanitizeParams
};