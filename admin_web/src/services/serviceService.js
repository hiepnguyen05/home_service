import { collection, getDocs, doc, getDoc } from 'firebase/firestore';
import { firestore } from '../firebase/config';

/**
 * Lấy danh sách tất cả dịch vụ
 * @returns {Promise<Array>} Danh sách dịch vụ
 */
export const getAllServices = async () => {
    try {
        const querySnapshot = await getDocs(collection(firestore, 'services'));
        return querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    } catch (error) {
        console.error('Error fetching services:', error);
        throw error;
    }
};

/**
 * Lấy thông tin một dịch vụ theo ID
 * @param {string} serviceId 
 * @returns {Promise<Object>} Thông tin dịch vụ
 */
export const getServiceById = async (serviceId) => {
    try {
        const docRef = doc(firestore, 'services', serviceId);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            return { id: docSnap.id, ...docSnap.data() };
        } else {
            console.log("No such service!");
            return null;
        }
    } catch (error) {
        console.error('Error fetching service:', error);
        throw error;
    }
};

/**
 * Lấy danh sách tất cả category
 * @returns {Promise<Array>} Danh sách category
 */
export const getAllCategories = async () => {
    try {
        const querySnapshot = await getDocs(collection(firestore, 'categories'));
        return querySnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));
    } catch (error) {
        console.error('Error fetching categories:', error);
        throw error;
    }
};
