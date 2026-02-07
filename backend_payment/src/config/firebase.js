const admin = require('firebase-admin');
const path = require('path');

// Đường dẫn đến file service account key
// Bạn cần tải file này từ Firebase Console và đặt vào folder root hoặc config
const serviceAccountPath = path.join(__dirname, '../../serviceAccountKey.json');

try {
    const serviceAccount = require(serviceAccountPath);
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        // databaseURL: "https://your-project.firebaseio.com" // Không cần thiết với Firestore
    });
    console.log('Firebase Admin Initialized successfully');
} catch (error) {
    console.error('Error initializing Firebase Admin:', error.message);
    console.log('Please make sure serviceAccountKey.json exists in root or config folder');
}

const db = admin.firestore();

module.exports = { admin, db };
