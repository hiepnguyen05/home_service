const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');

// Cau hinh luu tru cho file tai len
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    // Tao ten file duy nhat voi thoi gian
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const fileExtension = path.extname(file.originalname);
    const fileName = file.fieldname + '-' + uuidv4() + '-' + uniqueSuffix + fileExtension;
    cb(null, fileName);
  }
});

// Bo loc file chi chap nhan anh
const fileFilter = (req, file, cb) => {
  // Chi chap nhan anh
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Chi chap nhan file anh!'), false);
  }
};

// Cau hinh tai len multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // Gioi han kich thuoc file 5MB
  }
});

// Middleware tai len mot file
const uploadSingle = upload.single('avatar');

// Middleware tai len nhieu file
const uploadMultiple = upload.array('images', 5); // Toi da 5 anh

// Middleware xu ly loi tai len file
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'Kich thuoc file qua lon. Toi da 5MB.'
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        message: 'Qua nhieu file tai len. Toi da 5 file.'
      });
    }
    if (err.code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        success: false,
        message: 'Ten truong khong hop le trong tai len.'
      });
    }
  }

  if (err.message === 'Chi chap nhan file anh!') {
    return res.status(400).json({
      success: false,
      message: err.message
    });
  }

  // Chuyen loi khac cho middleware xu ly loi tiep theo
  next(err);
};

// Middleware tai len nhieu file cho worker application
const uploadWorkerFiles = upload.fields([
  { name: 'identity_front', maxCount: 1 },
  { name: 'identity_back', maxCount: 1 },
  { name: 'certificates', maxCount: 5 }
]);

module.exports = {
  uploadSingle,
  uploadMultiple,
  uploadWorkerFiles,
  handleUploadError
};