import { useState, useEffect, useCallback } from "react";
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp, query, orderBy } from "firebase/firestore";
import { useFirebase } from "../context/FirebaseContext";

export const useCategories = () => {
    const { firestore } = useFirebase();
    const [categories, setCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchCategories = useCallback(async () => {
        setLoading(true);
        setError(null);
        try {
            const q = query(collection(firestore, 'categories'), orderBy('order', 'asc'));
            const querySnapshot = await getDocs(q);
            const cats = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setCategories(cats);
        } catch (err) {
            console.error("Error fetching categories: ", err);
            setError("Không thể tải danh sách danh mục.");
        } finally {
            setLoading(false);
        }
    }, [firestore]);

    useEffect(() => {
        fetchCategories();
    }, [fetchCategories]);

    const addCategory = async (categoryData) => {
        try {
            await addDoc(collection(firestore, 'categories'), {
                ...categoryData,
                order: parseInt(categoryData.order) || 0,
                createdAt: serverTimestamp(),
                updatedAt: serverTimestamp()
            });
            await fetchCategories();
            return { success: true };
        } catch (err) {
            console.error("Error adding category: ", err);
            return { success: false, error: err.message };
        }
    };

    const updateCategory = async (id, categoryData) => {
        try {
            const categoryRef = doc(firestore, 'categories', id);
            await updateDoc(categoryRef, {
                ...categoryData,
                order: parseInt(categoryData.order) || 0,
                updatedAt: serverTimestamp()
            });
            await fetchCategories();
            return { success: true };
        } catch (err) {
            console.error("Error updating category: ", err);
            return { success: false, error: err.message };
        }
    };

    const deleteCategory = async (id) => {
        try {
            await deleteDoc(doc(firestore, 'categories', id));
            await fetchCategories();
            return { success: true };
        } catch (err) {
            console.error("Error deleting category: ", err);
            return { success: false, error: err.message };
        }
    };

    const toggleCategoryStatus = async (category) => {
        try {
            const categoryRef = doc(firestore, 'categories', category.id);
            await updateDoc(categoryRef, {
                isActive: !category.isActive, // Toggle status
                updatedAt: serverTimestamp()
            });
            // Update local state immediately for better UX
            setCategories(prev => prev.map(c =>
                c.id === category.id ? { ...c, isActive: !c.isActive } : c
            ));
            return { success: true };
        } catch (err) {
            console.error("Error toggling status: ", err);
            return { success: false, error: err.message };
        }
    };

    return {
        categories,
        loading,
        error,
        fetchCategories,
        addCategory,
        updateCategory,
        deleteCategory,
        toggleCategoryStatus
    };
};
