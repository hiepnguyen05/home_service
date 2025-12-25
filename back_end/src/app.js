const express = require('express')
require('dotenv').config({ silent: true })
const { connectDB } = require('./config/database')
const path = require('path')
const corsMiddleware = require('./middleware/corsMiddleware')
const requestLogger = require('./middleware/requestLogger')
const { sanitizeBody, sanitizeQuery, sanitizeParams } = require('./middleware/sanitizeMiddleware')

const app = express()

// Middleware ghi log yeu cau
app.use(requestLogger)

// Middleware xu ly CORS
app.use(corsMiddleware)

// Middleware lam sach du lieu dau vao
app.use(sanitizeBody)
app.use(sanitizeQuery)
app.use(sanitizeParams)

// Middleware phan tich JSON
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))

// Phuc vu tep tinh tu thu muc uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Xu ly loi toan cuc cho loi phan tich JSON
app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        return res.status(400).json({
            success: false,
            message: 'Dinh dang JSON khong hop le trong body yeu cau',
            error: 'Yeu cau JSON loi'
        });
    }
    next();
});

// Tuyen duong xac thuc
const authRoutes = require('./routes/authRoutes')
app.use('/api/auth', authRoutes);

// Tuyen duong nguoi dung
const userRoutes = require('./routes/userRoutes')
app.use('/api/users', userRoutes);

// Tuyen duong ho so
const profileRoutes = require('./routes/profileRoutes')
app.use('/api/profile', profileRoutes);

// Tuyen duong admin
const adminRoutes = require('./routes/adminRoutes')
app.use('/api/admin', adminRoutes);

// Tuyen duong worker applications
const workerApplicationRoutes = require('./routes/workerApplicationRoutes')
app.use('/api/worker-applications', workerApplicationRoutes);

// Import error handlers
const errorHandler = require('./middleware/errorHandler');
const notFoundHandler = require('./middleware/notFoundHandler');

// 404 handler - phải đặt sau tất cả routes
app.use(notFoundHandler);

// Global error handler - phải đặt cuối cùng
app.use(errorHandler);

// Kết nối database
connectDB()

module.exports = app