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
export const approveProvider = async (providerId, requestId) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);

        // 1. Lấy thông tin từ partner_requests để copy sang users
        // Nếu có requestId, lấy chính xác đơn đó, ngược lại dùng ID thợ để tìm đơn mới nhất
        let requestDetails = null;
        if (requestId) {
            const reqDoc = await getDoc(doc(firestore, 'partner_requests', requestId));
            if (reqDoc.exists()) {
                requestDetails = { id: reqDoc.id, ...reqDoc.data() };
            }
        }
        
        if (!requestDetails) {
            requestDetails = await getProviderRequestDetails(providerId);
        }

        let updateData = {
            isVerified: true,
            verificationStatus: 'verified',
            updatedAt: new Date(),
            isActive: true
        };

        if (requestDetails) {
            if (requestDetails.idFrontUrl) updateData.idFrontUrl = requestDetails.idFrontUrl;
            if (requestDetails.idBackUrl) updateData.idBackUrl = requestDetails.idBackUrl;
            if (requestDetails.certificates) updateData.certificates = requestDetails.certificates;
            if (requestDetails.services && Array.isArray(requestDetails.services)) {
                updateData.serviceIds = requestDetails.services.map(s => s.serviceId || s.id);
            }
            if (requestDetails.experienceYears) {
                updateData.experience = `${requestDetails.experienceYears} năm`;
            } else if (requestDetails.experience) {
                updateData.experience = requestDetails.experience;
            }
            if (requestDetails.portraitUrl) updateData.avatar_url = requestDetails.portraitUrl;
            if (requestDetails.bio) updateData.bio = requestDetails.bio;
        }

        updateData.role = 'provider';
        if (!updateData.createdAt) updateData.createdAt = new Date();

        // Fetch user data to use as fallback for name, avatar, etc.
        const userSnapshot = await getDoc(providerRef);
        const userData = userSnapshot.exists() ? userSnapshot.data() : {};

        // 1. Chuẩn bị dữ liệu services (Hợp nhất diff nếu có)
        let finalServices = (requestDetails && requestDetails.services) ? requestDetails.services : [];
        try {
            const providersRef = doc(firestore, 'providers', providerId);
            const providerSnapshot = await getDoc(providersRef);
            
                const changes = requestDetails.services || [];
                const isUpdate = requestDetails.requestType === 'update';
                
                let currentServices = [];
                
                // 1. Thử lấy từ providers.services
                if (providerSnapshot.exists()) {
                    currentServices = providerSnapshot.data()?.services || [];
                }
                
                // 2. Thử lấy từ users.services (Fallback)
                if (currentServices.length === 0) {
                    if (userSnapshot.exists()) {
                        currentServices = userData.services || [];
                    }
                }

                // 3. Fallback: Nếu vẫn trống nhưng có serviceIds (danh sách string), hãy bảo toàn chúng
                if (currentServices.length === 0) {
                    const idsInProvider = providerSnapshot.exists() ? (providerSnapshot.data()?.serviceIds || []) : [];
                    const idsInUser = userData.serviceIds || [];
                    const allIds = [...new Set([...idsInProvider, ...idsInUser])];
                    
                    if (allIds.length > 0) {
                        console.log(`[Approve] Reconstructing services from ${allIds.length} IDs for merge fallback`);
                        currentServices = allIds.map(id => (typeof id === 'string' ? { serviceId: id } : id));
                    }
                }

                console.log(`[Approve] Current services count: ${currentServices.length}, Changes count: ${changes.length}, Request type: ${requestDetails.requestType}`);

                // THỰC HIỆN MERGE: 
                // Ưu tiên merge nếu có currentServices HOẶC là request update
                // Chỉ overwrite hoàn toàn nếu là REGISTRATION nguyên bản và KHÔNG CÓ dữ liệu cũ nào.
                if (currentServices.length > 0 || isUpdate) {
                    console.log("[Approve] Performing MERGE to preserve existing services");
                    const baseServices = [...currentServices];
                    
                    changes.forEach(change => {
                        const changeId = change.serviceId || change.id;
                        const idx = baseServices.findIndex(s => (s.serviceId === changeId || s.id === changeId));
                        
                        if (change.changeType === 'added') {
                            if (idx === -1) baseServices.push(change);
                            else baseServices[idx] = { ...baseServices[idx], ...change };
                        } else if (change.changeType === 'updated') {
                            if (idx !== -1) baseServices[idx] = { ...baseServices[idx], ...change };
                            else baseServices.push(change);
                        } else if (change.changeType === 'deleted') {
                            if (idx !== -1) {
                                console.log(`[Approve] Removing service: ${changeId}`);
                                baseServices.splice(idx, 1);
                            }
                        } else {
                            // Default: Updated/Added
                            if (idx === -1) baseServices.push(change);
                            else baseServices[idx] = { ...baseServices[idx], ...change };
                        }
                    });
                    finalServices = baseServices;
                } else {
                    console.log("[Approve] No existing services found, taking changes as-is (Initial Registration)");
                    finalServices = changes;
                }
                
                console.log(`[Approve] Final joined services count: ${finalServices.length}`);
        } catch (e) {
            console.error('Error calculating final services:', e);
        }

        // 2. Cập nhật collection 'users'
        updateData = {
            ...updateData,
            isVerified: true,
            verificationStatus: 'verified',
            role: 'provider',
            updatedAt: new Date(),
            services: finalServices,
            serviceIds: finalServices.map(s => s.serviceId || s.id)
        };

        if (requestDetails && requestDetails.fullName) updateData.full_name = requestDetails.fullName;
        if (requestDetails && requestDetails.bio) updateData.bio = requestDetails.bio;

        await setDoc(providerRef, updateData, { merge: true });

        // 3. Đồng bộ sang collection 'providers'
        try {
            const providersRef = doc(firestore, 'providers', providerId);
            const providerSnapshot = await getDoc(providersRef);
            
            const providerSyncData = {
                updatedAt: new Date(),
                name: (requestDetails?.fullName || requestDetails?.name || updateData.full_name || userData.full_name || userData.name || 'Thợ'),
                services: finalServices,
                serviceIds: finalServices.map(s => s.serviceId || s.id)
            };

            // Avatar Sync: prioritize new request > user data > existing provider data
            const finalAvatarUrl = requestDetails?.portraitUrl || userData.avatar_url || userData.avatarUrl || userData.photoURL || providerSnapshot.data()?.avatarUrl || '';
            if (finalAvatarUrl) {
                providerSyncData.avatarUrl = finalAvatarUrl;
            }

            if (!providerSnapshot.exists()) {
                providerSyncData.isOnline = false;
                providerSyncData.rating = 5.0;
                providerSyncData.reviewCount = 0;
                providerSyncData.createdAt = new Date();
            }

            const prices = finalServices
                .map(s => parseFloat(s.price.toString().replace(/\D/g, '')))
                .filter(p => !isNaN(p) && p > 0);
            
            if (prices.length > 0) {
                providerSyncData.price = Math.min(...prices);
            }

            if (requestDetails && requestDetails.bio) providerSyncData.bio = requestDetails.bio;
            else if (updateData.bio) providerSyncData.bio = updateData.bio;
            
            await setDoc(providersRef, providerSyncData, { merge: true });
        } catch (syncError) {
            console.error('Error syncing to providers collection:', syncError);
        }

        // 4. Update Partner Request status
        // Nếu có requestId cụ thể, update đơn đó. Nếu không, query đơn mới nhất.
        if (requestId) {
            await updateDoc(doc(firestore, 'partner_requests', requestId), {
                status: 'approved',
                updatedAt: new Date()
            });
        } else {
            const q = query(
                collection(firestore, 'partner_requests'),
                where('userId', '==', providerId),
                where('status', '==', 'pending')
            );
            const requestSnapshot = await getDocs(q);
            const requestUpdatePromises = requestSnapshot.docs.map(d =>
                updateDoc(doc(firestore, 'partner_requests', d.id), {
                    status: 'approved',
                    updatedAt: new Date()
                })
            );
            await Promise.all(requestUpdatePromises);
        }

        return true;
    } catch (error) {
        console.error('Error approving provider:', error);
        throw error;
    }
};

/**
 * Từ chối thợ (Reject)
 */
export const rejectProvider = async (providerId, requestId, reason) => {
    try {
        const providerRef = doc(firestore, 'users', providerId);

        // 1. Update User status (chỉ khi có User)
        try {
            const userSnap = await getDoc(providerRef);
            if (userSnap.exists()) {
                await updateDoc(providerRef, {
                    isVerified: false,
                    verificationStatus: 'rejected',
                    updatedAt: new Date()
                });
            }
        } catch (e) {
            console.error('User might not exist for this request');
        }

        // 2. Update Partner Request status
        if (requestId) {
            await updateDoc(doc(firestore, 'partner_requests', requestId), {
                status: 'rejected',
                rejectReason: reason || 'Không có lý do cụ thể.',
                updatedAt: new Date()
            });
        } else {
            const q = query(
                collection(firestore, 'partner_requests'),
                where('userId', '==', providerId),
                where('status', '==', 'pending')
            );

            const requestSnapshot = await getDocs(q);
            const updatePromises = requestSnapshot.docs.map(d =>
                updateDoc(doc(firestore, 'partner_requests', d.id), {
                    status: 'rejected',
                    rejectReason: reason || 'Không có lý do cụ thể.',
                    updatedAt: new Date()
                })
            );
            
            await Promise.all(updatePromises);
        }

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
