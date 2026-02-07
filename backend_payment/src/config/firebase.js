const admin = require('firebase-admin');
const path = require('path');

// Đường dẫn đến file service account key
// Bạn cần tải file này từ Firebase Console và đặt vào folder root hoặc config
const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');

try {
    let serviceAccount;
    // Ưu tiên đọc từ biến môi trường (cho Render/Vercel)
    if (process.env.SERVICE_ACCOUNT_KEY) {
        serviceAccount = JSON.parse(process.env.SERVICE_ACCOUNT_KEY);
    } else {
        // Fallback đọc từ file local (cho development)
        serviceAccount = require(serviceAccountPath);
    }

    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log('Firebase Admin Initialized successfully');
} catch (error) {
    console.error('Error initializing Firebase Admin:', error.message);
    console.log('Please set SERVICE_ACCOUNT_KEY env var or ensure serviceAccountKey.json exists');
}

const db = admin.firestore();

module.exports = { admin, db };
