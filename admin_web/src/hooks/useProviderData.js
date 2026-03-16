import { useState, useEffect, useCallback } from 'react';
import { getAllProviders, getAllPartnerRequests, getUsersByIds } from '../services/providerService';
import { getAllServices, getAllCategories } from '../services/serviceService';

const useProviderData = () => {
    const [providers, setProviders] = useState([]);
    const [pendingRequests, setPendingRequests] = useState([]); // Separate state for pending requests
    const [rejectedRequests, setRejectedRequests] = useState([]); // Separate state for rejected requests
    const [serviceMap, setServiceMap] = useState({});
    const [serviceCategoryMap, setServiceCategoryMap] = useState({});
    const [loading, setLoading] = useState(true);
    const [categories, setCategories] = useState([]);
    const [services, setServices] = useState([]);
    const [error, setError] = useState(null);

    const fetchData = useCallback(async () => {
        try {
            setLoading(true);
            setError(null);

            const [providersData, servicesData, categoriesData, requestsData] = await Promise.all([
                getAllProviders(),
                getAllServices(),
                getAllCategories(),
                getAllPartnerRequests()
            ]);

            setCategories(categoriesData || []);
            setServices(servicesData || []);

            // --- Process Data ---

            // 1. Create Category Map: ID -> Name
            const categoriesMap = {};
            if (categoriesData) {
                categoriesData.forEach(c => {
                    categoriesMap[c.id] = c.name;
                });
            }

            // 2. Create Service Maps
            const nameMap = {};
            const catMap = {}; // ServiceID -> CategoryName

            if (servicesData) {
                servicesData.forEach(s => {
                    nameMap[s.id] = s.name;
                    const catId = s.category || s.categoryId;
                    const catName = categoriesMap[catId];
                    if (catName) {
                        catMap[s.id] = catName;
                    }
                });
            }

            setServiceMap(nameMap);
            setServiceCategoryMap(catMap);

            // 3. Process Pending Requests (from partner_requests)

            // 3.1 Fetch User Info for these requests
            const userIds = requestsData.map(req => req.userId).filter(Boolean);
            const usersList = await getUsersByIds([...new Set(userIds)]);
            const usersMap = {};
            usersList.forEach(u => {
                usersMap[u.id] = u;
            });

            // 3.2 Normalize data
            const normalizedRequests = requestsData.map(req => {
                const user = usersMap[req.userId] || {};

                return {
                    id: req.id, // Sử dụng requestId làm ID chính để UI phân biệt các đơn khác nhau
                    userId: req.userId,
                    requestId: req.id,

                    // Ưu tiên lấy tên từ User profile, sau đó đến request
                    full_name: user.full_name || user.displayName || user.name || req.name || req.full_name || 'Chưa cập nhật',
                    email: user.email || req.email || '---',
                    phoneNumber: user.phoneNumber || user.phone || req.phone || req.phoneNumber || '---',

                    role: 'provider',
                    verificationStatus: 'pending',
                    isActive: false,
                    isVerified: false,
                    createdAt: req.createdAt,

                    // Map services
                    serviceIds: Array.isArray(req.services)
                        ? req.services.map(s => s.serviceId || s.id || s)
                        : [],

                    // Giữ nguyên array services để hiển thị giá
                    requestedServices: Array.isArray(req.services) ? req.services : [],

                    // Merge các trường khác
                    ...user, // Merge user data trước
                    ...req,  // Merge request data sau để ưu tiên status của request
                };
            });

            // Sort requests by createdAt desc
            normalizedRequests.sort((a, b) => {
                const timeA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt || 0);
                const timeB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt || 0);
                return timeB - timeA;
            });

            // Filter only actual pending requests
            const actualPending = normalizedRequests.filter(req => {
                return req.status === 'pending';
            });

            // Filter rejected requests (from partner_requests)
            const rejectedReqs = normalizedRequests.filter(req => {
                return req.status === 'rejected';
            });

            setPendingRequests(actualPending);
            setRejectedRequests(rejectedReqs);
            // We can return rejectedReqs if we want to show them separately, 
            // OR we can just return normalizedRequests and let the UI filter.
            // But strict separation is better.

            // Let's add a state for rejectedRequests if needed, or just return it?
            // The hook currently only has `setPendingRequests`.
            // Let's modify the return to include `rejectedRequests`.
            // But wait, `providers` (from users collection) also contains rejected users?
            // Yes, `getAllProviders` fetches users where role='provider'.
            // So `providers` has `verificationStatus='rejected'`.
            // BUT, `partner_requests` might have requests that don't have a user yet (or user deleted).
            // So we should merge them or provide a separate list.

            // For now, let's just make `rejectedRequests` available in the scope to return it.
            // I need to add state for it or just include it in the return object if I calculate it here.
            // Since `fetchData` sets state, I should add a state `setRejectedRequests`.

            // 4. Process Existing Providers (from users collection)
            // Fix missing serviceIds using partner_requests if needed (logic from before)
            const requestServiceMap = {};
            if (requestsData) {
                requestsData.forEach(req => {
                    if (req.userId && req.services) { // userId in request maps to id in users
                        const sIds = Array.isArray(req.services)
                            ? req.services.map(s => s.serviceId || s.id || s)
                            : [];
                        requestServiceMap[req.userId] = sIds;
                    }
                });
            }

            const mergedProviders = providersData.map(p => {
                if (!p.serviceIds || p.serviceIds.length === 0) {
                    // Check if there is a matching request by ID or userId logic?
                    // Usually providersData items are users. partner_requests has userId pointing to them IF they are linked.
                    // But here we are just ensuring data consistency.
                    return { ...p, serviceIds: requestServiceMap[p.id] || [] };
                }
                return p;
            });

            setProviders(mergedProviders);
            setLoading(false);

        } catch (err) {
            console.error('Error fetching provider data:', err);
            setError('Không thể tải dữ liệu. Vui lòng thử lại.');
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchData();
    }, [fetchData]);

    return {
        providers,
        pendingRequests, // Export pending requests
        rejectedRequests, // Export rejected requests
        categories, // Export raw categories
        services,   // Export raw services
        serviceMap,
        serviceCategoryMap,
        loading,
        error,
        refreshData: fetchData
    };
};

export default useProviderData;
