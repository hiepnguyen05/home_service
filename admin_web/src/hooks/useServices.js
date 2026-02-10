import { useState, useEffect, useCallback } from "react";
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp, query, orderBy } from "firebase/firestore";
import { useFirebase } from "../context/FirebaseContext";

export const useServices = () => {
    const { firestore } = useFirebase();
    const [services, setServices] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchServices = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const q = query(collection(firestore, 'services'), orderBy('createdAt', 'desc'));
            const querySnapshot = await getDocs(q);
            const servicesList = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setServices(servicesList);
        } catch (err) {
            console.error("Error fetching services: ", err);
            setError("Không thể tải danh sách dịch vụ.");
        } finally {
            setLoading(false);
        }
    }, [firestore]);

    useEffect(() => {
        fetchServices();
    }, [fetchServices]);

    const addService = async (serviceData) => {
        try {
            await addDoc(collection(firestore, 'services'), {
                ...serviceData,
                minPrice: Number(serviceData.minPrice) || 0,
                maxPrice: Number(serviceData.maxPrice) || 0,
                suggestedPrice: Number(serviceData.suggestedPrice) || 0,
                rating: 0,
                reviewCount: 0,
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp()
            });
            await fetchServices();
            return { success: true };
        } catch (err) {
            console.error("Error adding service: ", err);
            return { success: false, error: err.message };
        }
    };

    const updateService = async (id, serviceData) => {
        try {
            const serviceRef = doc(firestore, 'services', id);

            // Remove createdAt if it exists in serviceData to prevent overwriting
            const { createdAt, ...dataToUpdate } = serviceData;

            await updateDoc(serviceRef, {
                ...dataToUpdate,
                minPrice: Number(serviceData.minPrice) || 0,
                maxPrice: Number(serviceData.maxPrice) || 0,
                suggestedPrice: Number(serviceData.suggestedPrice) || 0,
                updatedAt: serverTimestamp()
            });
            await fetchServices();
            return { success: true };
        } catch (err) {
            console.error("Error updating service: ", err);
            return { success: false, error: err.message };
        }
    };

    const deleteService = async (id) => {
        try {
            await deleteDoc(doc(firestore, 'services', id));
            await fetchServices();
            return { success: true };
        } catch (err) {
            console.error("Error deleting service: ", err);
            return { success: false, error: err.message };
        }
    };

    const toggleServiceStatus = async (service) => {
        try {
            const serviceRef = doc(firestore, 'services', service.id);
            await updateDoc(serviceRef, {
                isActive: !service.isActive,
                updatedAt: serverTimestamp()
            });

            // Optimistic update
            setServices(prev => prev.map(s =>
                s.id === service.id ? { ...s, isActive: !s.isActive } : s
            ));
            return { success: true };
        } catch (err) {
            console.error("Error toggling service status: ", err);
            return { success: false, error: err.message };
        }
    };

    return {
        services,
        loading,
        error,
        fetchServices,
        addService,
        updateService,
        deleteService,
        toggleServiceStatus
    };
};
