// Middleware ghi log thong tin yeu cau de theo doi va go loi
const requestLogger = (req, res, next) => {
  // Chi ghi log trong moi truong phat trien de tranh anh huong toi hieu suat
  if (process.env.NODE_ENV === 'development') {
    const timestamp = new Date().toISOString();
    const method = req.method;
    const url = req.url;
    const ip = req.ip || req.connection.remoteAddress;
    
    // Ghi log thoi gian, phuong thuc, duong dan va dia chi IP
    console.log(`[${timestamp}] ${method} ${url} - IP: ${ip}`);
  }
  
  next();
};

module.exports = requestLogger;