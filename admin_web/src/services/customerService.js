import { firestore } from '../firebase/config';
import { collection, query, where, getDocs, doc, getDoc, updateDoc, deleteDoc, setDoc } from 'firebase/firestore';

/**
 * Lấy tất cả khách hàng (users có role = 'customer')
 */
export const getAllCustomers = async () => {
    try {
        const usersRef = collection(firestore, 'users');
        const q = query(
            usersRef,
            where('role', '==', 'customer')
        );

        const querySnapshot = await getDocs(q);
        const customers = [];

        querySnapshot.forEach((doc) => {
            const data = doc.data();
            customers.push({
                id: doc.id,
                ...data,
                createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(data.createdAt)
            });
        });

        // Sắp xếp client-side
        customers.sort((a, b) => b.createdAt - a.createdAt);

        return customers;
    } catch (error) {
        console.error('Error fetching customers:', error);
        throw error;
    }
};

/**
 * Lấy thông tin chi tiết một khách hàng
 */
export const getCustomerById = async (customerId) => {
    try {
        const customerRef = doc(firestore, 'users', customerId);
        const customerSnap = await getDoc(customerRef);

        if (customerSnap.exists()) {
            return {
                id: customerSnap.id,
                ...customerSnap.data()
            };
        } else {
            throw new Error('Customer not found');
        }
    } catch (error) {
        console.error('Error fetching customer:', error);
        throw error;
    }
};


/**
 */
export const createCustomer = async (data) => {
    try {
        const newCustomerRef = doc(collection(firestore, 'users'));
        const timestamp = new Date();

        await setDoc(newCustomerRef, {
            ...data,
            id: newCustomerRef.id,
            role: data.role || 'customer',
            createdAt: timestamp,
            updatedAt: timestamp,
            isActive: true, // Mặc định active
            isVerified: true // Mặc định verify khi admin tạo
        });

        return newCustomerRef.id;
    } catch (error) {
        console.error('Error creating customer:', error);
        throw error;
    }
};

/**
 * Cập nhật thông tin khách hàng
 */
export const updateCustomer = async (customerId, data) => {
    try {
        const customerRef = doc(firestore, 'users', customerId);
        await updateDoc(customerRef, {
            ...data,
            updatedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error updating customer:', error);
        throw error;
    }
};

/**
 * Xóa khách hàng (soft delete - chỉ cập nhật status)
 */
export const deleteCustomer = async (customerId) => {
    try {
        const customerRef = doc(firestore, 'users', customerId);
        await updateDoc(customerRef, {
            isActive: false,
            deletedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error deleting customer:', error);
        throw error;
    }
};

/**
 * Đếm số đơn hàng của khách hàng
 */
export const getCustomerOrderCount = async (customerId) => {
    try {
        const bookingsRef = collection(firestore, 'bookings');
        const q = query(bookingsRef, where('customerId', '==', customerId));
        const querySnapshot = await getDocs(q);
        return querySnapshot.size;
    } catch (error) {
        console.error('Error counting customer orders:', error);
        return 0;
    }
};

/**
 * Tìm kiếm khách hàng
 */
export const searchCustomers = async (searchTerm) => {
    try {
        const usersRef = collection(firestore, 'users');
        const q = query(usersRef, where('role', '==', 'customer'));

        const querySnapshot = await getDocs(q);
        const customers = [];

        querySnapshot.forEach((doc) => {
            const data = doc.data();
            const searchLower = searchTerm.toLowerCase();

            // Tìm kiếm trong name, email, phoneNumber
            if (
                (data.name && data.name.toLowerCase().includes(searchLower)) ||
                (data.email && data.email.toLowerCase().includes(searchLower)) ||
                (data.phoneNumber && data.phoneNumber.includes(searchTerm))
            ) {
                customers.push({
                    id: doc.id,
                    ...data
                });
            }
        });

        return customers;
    } catch (error) {
        console.error('Error searching customers:', error);
        throw error;
    }
};
