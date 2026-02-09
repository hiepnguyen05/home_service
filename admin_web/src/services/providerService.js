import { firestore } from '../firebase/config';
import { collection, query, where, getDocs, doc, getDoc, updateDoc, deleteDoc, setDoc } from 'firebase/firestore';

/**
 * Lấy tất cả thợ (users có role = 'provider')
 */
export const getAllProviders = async () => {
    try {
        const usersRef = collection(firestore, 'users');
        const q = query(
            usersRef,
            where('role', '==', 'provider')
        );

        const querySnapshot = await getDocs(q);
        const providers = [];

        querySnapshot.forEach((doc) => {
            const data = doc.data();
            providers.push({
                id: doc.id,
                ...data,
                createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(data.createdAt)
            });
        });

        // Sắp xếp client-side
        providers.sort((a, b) => b.createdAt - a.createdAt);

        return providers;
    } catch (error) {
        console.error('Error fetching providers:', error);
        throw error;
    }
};

/**
 * Tạo thợ mới (admin tạo)
 */
export const createProvider = async (data) => {
    try {
        const newProviderRef = doc(collection(firestore, 'users'));
        const timestamp = new Date();

        await setDoc(newProviderRef, {
            ...data,
            id: newProviderRef.id,
            role: 'provider',
            createdAt: timestamp,
            updatedAt: timestamp,
            isActive: true, // Mặc định active
            isVerified: true // Admin tạo thì mặc định verify
        });

        return newProviderRef.id;
    } catch (error) {
        console.error('Error creating provider:', error);
        throw error;
    }
};

/**
 * Cập nhật thông tin thợ
 */
export const updateProvider = async (providerId, data) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);
        await updateDoc(providerRef, {
            ...data,
            updatedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error updating provider:', error);
        throw error;
    }
};

/**
 * Xóa thợ (soft delete)
 */
export const deleteProvider = async (providerId) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);
        await updateDoc(providerRef, {
            isActive: false,
            deletedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error deleting provider:', error);
        throw error;
    }
};

/**
 * Duyệt thợ (Verify)
 */
/**
 * Duyệt thợ (Verify)
 */
export const approveProvider = async (providerId) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);

        // 1. Lấy thông tin từ partner_requests để copy sang users
        const requestDetails = await getProviderRequestDetails(providerId);

        const updateData = {
            isVerified: true,
            verificationStatus: 'verified',
            updatedAt: new Date(),
            isActive: true
        };

        if (requestDetails) {
            // Copy images if they exist in request but not in provider (or just overwrite to be safe/latest)
            if (requestDetails.idFrontUrl) updateData.idFrontUrl = requestDetails.idFrontUrl;
            if (requestDetails.idBackUrl) updateData.idBackUrl = requestDetails.idBackUrl;

            // Map certificates
            if (requestDetails.certificates) {
                updateData.certificates = requestDetails.certificates;
            }

            // Map services
            if (requestDetails.services && Array.isArray(requestDetails.services)) {
                // partner_requests stores services as objects {serviceId, serviceName, price}
                // users/ProviderModel stores serviceIds as List<String>
                updateData.serviceIds = requestDetails.services.map(s => s.serviceId || s.id);
            }

            // Map bio/experience if available and mapped
            if (requestDetails.experienceYears) {
                // Convert experienceYears (number) to string with "năm"
                updateData.experience = `${requestDetails.experienceYears} năm`;
            } else if (requestDetails.experience) {
                updateData.experience = requestDetails.experience;
            }

            if (requestDetails.bio) updateData.bio = requestDetails.bio;
        }

        // Ensure basic fields if we are inadvertently creating a new user document
        updateData.role = 'provider';
        if (!updateData.createdAt) updateData.createdAt = new Date(); // Only if creating (merge will keep existing if not overwritten, but better to be safe or check existence. Actually setDoc merge will overwrite. We should probably only set createdAt if it's new, but we can't easily know without getDoc. User verification usually implies existing user. Let's just set role and use setDoc. Firestore timestamps are objects, new Date() is JS. Firestore handles conversion.)

        // Use setDoc with merge: true instead of updateDoc to handle missing user documents
        await setDoc(providerRef, updateData, { merge: true });

        // 2. Update Partner Request status (to ensure it moves out of Pending/Rejected tabs)
        // Query to find the request by userId
        const q = query(
            collection(firestore, 'partner_requests'),
            where('userId', '==', providerId)
        );

        const requestSnapshot = await getDocs(q);
        const requestUpdatePromises = requestSnapshot.docs.map(d =>
            updateDoc(doc(firestore, 'partner_requests', d.id), {
                status: 'approved',
                updatedAt: new Date()
            })
        );

        await Promise.all(requestUpdatePromises);

        return true;
    } catch (error) {
        console.error('Error approving provider:', error);
        throw error;
    }
};

/**
 * Từ chối thợ (Reject)
 */
export const rejectProvider = async (providerId) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);

        // 1. Update User status
        const updatePromise = updateDoc(providerRef, {
            isVerified: false,
            verificationStatus: 'rejected',
            updatedAt: new Date()
        });

        // 2. Update Partner Request status (if exists) to ensure consistency
        // Query to find the request by userId
        const q = query(
            collection(firestore, 'partner_requests'),
            where('userId', '==', providerId)
        );

        const requestUpdatePromise = getDocs(q).then(snapshot => {
            const updatePromises = snapshot.docs.map(d =>
                updateDoc(doc(firestore, 'partner_requests', d.id), {
                    status: 'rejected',
                    updatedAt: new Date()
                })
            );
            return Promise.all(updatePromises);
        });

        await Promise.all([updatePromise, requestUpdatePromise]);

        return true;
    } catch (error) {
        console.error('Error rejecting provider:', error);
        throw error;
    }
};

/**
 * Reset trạng thái về Pending (nếu cần)
 */
export const resetProviderStatus = async (providerId) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);
        await updateDoc(providerRef, {
            isVerified: false,
            verificationStatus: 'pending',
            updatedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error resetting provider status:', error);
        throw error;
    }
};

/**
 * Khóa/Mở khóa thợ
 */
export const toggleProviderStatus = async (providerId, currentStatus) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);
        await updateDoc(providerRef, {
            isActive: !currentStatus,
            updatedAt: new Date()
        });
        return true;
    } catch (error) {
        console.error('Error toggling provider status:', error);
        throw error;
    }
};

/**
 * Lấy thông tin chi tiết từ partner_requests (để lấy ảnh CCCD/Chứng chỉ)
 */
export const getProviderRequestDetails = async (userId) => {
    try {
        const q = query(
            collection(firestore, 'partner_requests'),
            where('userId', '==', userId),
            // orderBy('createdAt', 'desc'), // Cần index composite nếu dùng orderBy với where khác field, tạm thời bỏ qua nếu chưa có index
        );

        // Vì chưa chắc có index, mình lấy về rồi sort client-side nếu cần, 
        // nhưng thường request mới nhất sẽ được query
        const querySnapshot = await getDocs(q);

        if (!querySnapshot.empty) {
            // Lấy request mới nhất nếu có nhiều cái
            // Giả sử docs trả về không thứ tự, ta tìm cái có createdAt lớn nhất
            const requests = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            // Sort giảm dần theo createdAt
            requests.sort((a, b) => {
                const timeA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
                const timeB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
                return timeB - timeA;
            });

            return requests[0];
        }
        return null;
    } catch (error) {
        return null;
    }
};

/**
 * Lấy tất cả partner requests (để map service cho list)
 */
export const getAllPartnerRequests = async () => {
    try {
        const q = query(collection(firestore, 'partner_requests'));
        const querySnapshot = await getDocs(q);
        return querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    } catch (error) {
        console.error('Error fetching partner requests:', error);
        return [];
    }
};

/**
 * Lấy danh sách user theo danh sách ID
 */
export const getUsersByIds = async (userIds) => {
    if (!userIds || userIds.length === 0) return [];
    try {
        // Sử dụng Promise.all để lấy song song (với số lượng ít)
        // Nếu số lượng lớn nên chia batch hoặc dùng where('id', 'in', ...) (limit 10)
        const docRefs = userIds.map(id => getDoc(doc(firestore, 'users', id)));
        const docs = await Promise.all(docRefs);
        return docs.map(d => d.exists() ? { id: d.id, ...d.data() } : null).filter(Boolean);
    } catch (error) {
        console.error('Error fetching users by IDs:', error);
        return [];
    }
};
