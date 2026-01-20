// Middleware xu ly CORS
const corsMiddleware = (req, res, next) => {
  // Cho phep tat ca cac origin trong moi truong phat trien
  res.header('Access-Control-Allow-Origin', '*');
  
  // Cac header duoc phep
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  // Cac phuong thuc duoc phep
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  
  // Cho phep gui cookie
  res.header('Access-Control-Allow-Credentials', 'true');
  
  // Neu la yeu cau OPTIONS (preflight request) thi tra ve 200
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  next();
};

module.exports = corsMiddleware;