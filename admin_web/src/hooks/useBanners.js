import { useState, useEffect, useCallback } from "react";
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp, query, orderBy } from "firebase/firestore";
import { useFirebase } from "../context/FirebaseContext";
import { uploadToCloudinary } from "../utils/cloudinaryUtils";

export const useBanners = () => {
    const { firestore } = useFirebase();
    const [banners, setBanners] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchBanners = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const q = query(collection(firestore, 'banners'), orderBy('order', 'asc'));
            const querySnapshot = await getDocs(q);
            const data = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setBanners(data);
        } catch (err) {
            console.error("Error fetching banners: ", err);
            setError("Không thể tải danh sách banner.");
        } finally {
            setLoading(false);
        }
    }, [firestore]);

    const uploadImage = async (file) => {
        try {
            const url = await uploadToCloudinary(file, 'banners');
            return { success: true, url };
        } catch (err) {
            console.error("Error uploading image to Cloudinary: ", err);
            return { success: false, error: err.message };
        }
    };

    useEffect(() => {
        fetchBanners();
    }, [fetchBanners]);

    const addBanner = async (bannerData) => {
        try {
            await addDoc(collection(firestore, 'banners'), {
                imageUrl: bannerData.imageUrl,
                order: parseInt(bannerData.order) || 0,
                isActive: bannerData.isActive ?? true,
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp()
            });
            await fetchBanners();
            return { success: true };
        } catch (err) {
            console.error("Error adding banner: ", err);
            return { success: false, error: err.message };
        }
    };

    const updateBanner = async (id, bannerData) => {
        try {
            const bannerRef = doc(firestore, 'banners', id);
            await updateDoc(bannerRef, {
                imageUrl: bannerData.imageUrl,
                order: parseInt(bannerData.order) || 0,
                isActive: bannerData.isActive ?? true,
                updatedAt: serverTimestamp()
            });
            await fetchBanners();
            return { success: true };
        } catch (err) {
            console.error("Error updating banner: ", err);
            return { success: false, error: err.message };
        }
    };

    const deleteBanner = async (id) => {
        try {
            await deleteDoc(doc(firestore, 'banners', id));
            await fetchBanners();
            return { success: true };
        } catch (err) {
            console.error("Error deleting banner: ", err);
            return { success: false, error: err.message };
        }
    };

    const toggleBannerStatus = async (banner) => {
        try {
            const bannerRef = doc(firestore, 'banners', banner.id);
            await updateDoc(bannerRef, {
                isActive: !banner.isActive,
                updatedAt: serverTimestamp()
            });
            setBanners(prev => prev.map(b =>
                b.id === banner.id ? { ...b, isActive: !b.isActive } : b
            ));
            return { success: true };
        } catch (err) {
            console.error("Error toggling status: ", err);
            return { success: false, error: err.message };
        }
    };

    return {
        banners,
        loading,
        error,
        fetchBanners,
        uploadImage,
        addBanner,
        updateBanner,
        deleteBanner,
        toggleBannerStatus
    };
};
