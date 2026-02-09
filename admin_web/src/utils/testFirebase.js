import { firestore } from '../firebase/config';
import { collection, getDocs, query, where } from 'firebase/firestore';

/**
 * Test Firebase connection và kiểm tra dữ liệu khách hàng
 */
export const testFirebaseConnection = async () => {
    console.log('🔍 Testing Firebase connection...');

    try {
        // Test 1: Kết nối cơ bản
        console.log('✅ Firebase initialized successfully');

        // Test 2: Lấy danh sách users
        const usersRef = collection(firestore, 'users');
        const usersSnapshot = await getDocs(usersRef);
        console.log(`📊 Total users in database: ${usersSnapshot.size}`);

        // Test 3: Lấy danh sách customers
        const customersQuery = query(usersRef, where('role', '==', 'customer'));
        const customersSnapshot = await getDocs(customersQuery);
        console.log(`👥 Total customers: ${customersSnapshot.size}`);

        // Test 4: Hiển thị thông tin một số customers
        if (customersSnapshot.size > 0) {
            console.log('\n📋 Sample customers:');
            customersSnapshot.forEach((doc, index) => {
                if (index < 3) { // Chỉ hiển thị 3 khách hàng đầu
                    const data = doc.data();
                    console.log(`\n${index + 1}. ${data.name || data.displayName || 'No name'}`);
                    console.log(`   Email: ${data.email || 'N/A'}`);
                    console.log(`   Phone: ${data.phoneNumber || data.phone || 'N/A'}`);
                    console.log(`   Status: ${data.isActive === false ? 'Inactive' : 'Active'}`);
                }
            });
        } else {
            console.log('⚠️ No customers found in database');
            console.log('💡 Tip: Make sure you have users with role="customer" in Firestore');
        }

        // Test 5: Kiểm tra collection bookings
        const bookingsRef = collection(firestore, 'bookings');
        const bookingsSnapshot = await getDocs(bookingsRef);
        console.log(`\n📦 Total bookings: ${bookingsSnapshot.size}`);

        console.log('\n✅ All tests passed!');
        return true;

    } catch (error) {
        console.error('❌ Firebase connection error:', error);
        console.error('Error details:', error.message);
        return false;
    }
};

// Uncomment để chạy test ngay khi import
// testFirebaseConnection();
