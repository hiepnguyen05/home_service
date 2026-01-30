import React, { useState, useEffect } from "react";
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, serverTimestamp, query, orderBy } from "firebase/firestore";
import { useFirebase } from "../../context/FirebaseContext";
import { FaEdit, FaTrash, FaPlus, FaSave, FaTimes } from "react-icons/fa";
import IconPicker from "../../components/Form/IconPicker";
import { getIconComponent } from "../../constants/icons";

const CategoriesManager = () => {
    const { firestore } = useFirebase();
    const [categories, setCategories] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [currentCategory, setCurrentCategory] = useState({ name: '', iconName: 'cleaning_services', order: 1, isActive: true });
    const [editingId, setEditingId] = useState(null);

    // Fetch categories
    const fetchCategories = async () => {
        setLoading(true);
        try {
            const q = query(collection(firestore, 'categories'), orderBy('order', 'asc'));
            const querySnapshot = await getDocs(q);
            const cats = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setCategories(cats);
        } catch (error) {
            console.error("Error fetching categories: ", error);
            alert('Lỗi tải danh mục!');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchCategories();
    }, []);

    // Handle Submit (Add/Edit)
    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editingId) {
                // Edit mode
                const categoryRef = doc(firestore, 'categories', editingId);
                await updateDoc(categoryRef, {
                    name: currentCategory.name,
                    iconName: currentCategory.iconName,
                    order: parseInt(currentCategory.order),
                    isActive: currentCategory.isActive,
                    updatedAt: serverTimestamp()
                });
                alert('Cập nhật thành công!');
            } else {
                // Add mode
                await addDoc(collection(firestore, 'categories'), {
                    ...currentCategory,
                    order: parseInt(currentCategory.order),
                    createdAt: serverTimestamp()
                });
                alert('Thêm mới thành công!');
            }
            closeModal();
            fetchCategories();
        } catch (error) {
            console.error("Error saving category: ", error);
            alert('Có lỗi xảy ra!');
        }
    };

    // Delete
    const handleDelete = async (id, name) => {
        if (window.confirm(`Bạn chắc chắn muốn xóa danh mục "${name}"?`)) {
            try {
                await deleteDoc(doc(firestore, 'categories', id));
                fetchCategories();
            } catch (error) {
                console.error("Error deleting: ", error);
                alert('Lỗi xóa danh mục!');
            }
        }
    };

    const openModal = (category = null) => {
        if (category) {
            setEditingId(category.id);
            setCurrentCategory(category);
        } else {
            setEditingId(null);
            setCurrentCategory({ name: '', iconName: 'cleaning_services', order: categories.length + 1, isActive: true });
        }
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        setEditingId(null);
    };

    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Quản lý Danh mục</h1>
                <button
                    onClick={() => openModal()}
                    className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition"
                >
                    <FaPlus /> Thêm Danh mục
                </button>
            </div>

            {loading ? (
                <div className="text-center py-10">Đang tải...</div>
            ) : (
                <div className="bg-white rounded-xl shadow-sm overflow-hidden border border-gray-200">
                    <table className="w-full text-left border-collapse">
                        <thead className="bg-gray-100 text-gray-700">
                            <tr>
                                <th className="p-4 border-b">Thứ tự</th>
                                <th className="p-4 border-b">Icon</th>
                                <th className="p-4 border-b">Tên danh mục</th>
                                <th className="p-4 border-b">Mã Icon</th>
                                <th className="p-4 border-b">Trạng thái</th>
                                <th className="p-4 border-b text-center">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            {categories.map((cat) => {
                                const IconComp = getIconComponent(cat.iconName);
                                return (
                                    <tr key={cat.id} className="hover:bg-gray-50 border-b last:border-0 transition-colors">
                                        <td className="p-4 font-medium">{cat.order}</td>
                                        <td className="p-4">
                                            <div className="w-10 h-10 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                                                <IconComp size={24} />
                                            </div>
                                        </td>
                                        <td className="p-4 font-semibold text-gray-900">{cat.name}</td>
                                        <td className="p-4 font-mono text-xs text-gray-500">{cat.iconName}</td>
                                        <td className="p-4">
                                            <span className={`px-2 py-1 rounded-full text-xs font-bold ${cat.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                                {cat.isActive ? 'Hiển thị' : 'Ẩn'}
                                            </span>
                                        </td>
                                        <td className="p-4 flex justify-center gap-3">
                                            <button onClick={() => openModal(cat)} className="text-blue-500 hover:text-blue-700 p-2 bg-blue-50 rounded-lg transition-colors">
                                                <FaEdit size={16} />
                                            </button>
                                            <button onClick={() => handleDelete(cat.id, cat.name)} className="text-red-500 hover:text-red-700 p-2 bg-red-50 rounded-lg transition-colors">
                                                <FaTrash size={16} />
                                            </button>
                                        </td>
                                    </tr>
                                )
                            })}
                            {categories.length === 0 && (
                                <tr>
                                    <td colSpan="6" className="p-8 text-center text-gray-500">Chưa có danh mục nào.</td>
                                </tr>
                            )}
                        </tbody>
                    </table>
                </div>
            )}

            {/* MODAL */}
            {isModalOpen && (
                <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-xl shadow-2xl w-full max-w-lg overflow-hidden animate-fade-in-up">
                        <div className="flex justify-between items-center p-4 border-b border-gray-100 bg-gray-50">
                            <h2 className="text-xl font-bold text-gray-800">{editingId ? 'Sửa Danh mục' : 'Thêm Danh mục mới'}</h2>
                            <button onClick={closeModal} className="text-gray-400 hover:text-gray-600 transition-colors"><FaTimes size={20} /></button>
                        </div>

                        <div className="p-6">
                            <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Tên danh mục <span className="text-red-500">*</span></label>
                                    <input
                                        type="text"
                                        required
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                                        value={currentCategory.name}
                                        onChange={(e) => setCurrentCategory({ ...currentCategory, name: e.target.value })}
                                        placeholder="Ví dụ: Điện, Nước..."
                                    />
                                </div>

                                <IconPicker
                                    selectedIcon={currentCategory.iconName}
                                    onSelect={(name) => setCurrentCategory({ ...currentCategory, iconName: name })}
                                />

                                <div className="flex gap-4">
                                    <div className="flex-1">
                                        <label className="block text-sm font-medium text-gray-700 mb-1">Thứ tự hiển thị</label>
                                        <input
                                            type="number"
                                            required
                                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                                            value={currentCategory.order}
                                            onChange={(e) => setCurrentCategory({ ...currentCategory, order: e.target.value })}
                                        />
                                    </div>
                                    <div className="flex-1 flex items-end pb-2">
                                        <label className="flex items-center cursor-pointer gap-2 select-none hover:bg-gray-50 p-2 rounded-lg w-full transition-colors">
                                            <input
                                                type="checkbox"
                                                className="w-5 h-5 text-blue-600 rounded focus:ring-blue-500 border-gray-300"
                                                checked={currentCategory.isActive}
                                                onChange={(e) => setCurrentCategory({ ...currentCategory, isActive: e.target.checked })}
                                            />
                                            <span className="text-gray-700 font-medium">Đang hoạt động</span>
                                        </label>
                                    </div>
                                </div>

                                <div className="flex justify-end gap-3 mt-4 pt-4 border-t border-gray-100">
                                    <button type="button" onClick={closeModal} className="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded-lg font-medium transition-colors">Hủy</button>
                                    <button type="submit" className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 flex items-center gap-2 font-medium shadow-md shadow-blue-200 transition-all hover:shadow-lg">
                                        <FaSave /> {editingId ? 'Cập nhật' : 'Lưu lại'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default CategoriesManager;
