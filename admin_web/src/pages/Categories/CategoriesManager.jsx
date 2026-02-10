import React, { useState } from "react";
import { FaPlus, FaSearch } from "react-icons/fa";
import { useCategories } from "../../hooks/useCategories";
import CategoryTable from "./components/CategoryTable";
import CategoryModal from "./components/CategoryModal";

const CategoriesManager = () => {
    const { categories, loading, error, addCategory, updateCategory, deleteCategory, toggleCategoryStatus } = useCategories();
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingCategory, setEditingCategory] = useState(null);
    const [searchTerm, setSearchTerm] = useState("");

    const handleOpenModal = (category = null) => {
        setEditingCategory(category);
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setEditingCategory(null);
    };

    const handleSubmit = async (formData) => {
        let result;
        if (editingCategory) {
            result = await updateCategory(editingCategory.id, formData);
        } else {
            result = await addCategory(formData);
        }

        if (result.success) {
            handleCloseModal();
        } else {
            alert("Có lỗi xảy ra: " + result.error);
        }
    };

    const handleDelete = async (id, name) => {
        if (window.confirm(`Bạn có chắc chắn muốn xóa danh mục "${name}" không?`)) {
            const result = await deleteCategory(id);
            if (!result.success) {
                alert("Lỗi khi xóa: " + result.error);
            }
        }
    };

    // Filter categories
    const filteredCategories = categories.filter(cat =>
        cat.name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="p-8 bg-gray-50 min-h-screen font-sans">
            {/* Header Section */}
            <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
                <div>
                    <h1 className="text-3xl font-bold text-gray-800">Quản lý Danh mục</h1>
                    <p className="text-gray-500 mt-1">Quản lý các loại dịch vụ trong hệ thống</p>
                </div>

                <div className="flex items-center gap-3 w-full md:w-auto">
                    {/* Search Bar */}
                    <div className="relative flex-1 md:w-64">
                        <FaSearch className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Tìm kiếm danh mục..."
                            className="w-full pl-10 pr-4 py-2.5 rounded-xl border border-gray-200 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all outline-none"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>

                    <button
                        onClick={() => handleOpenModal()}
                        className="flex items-center gap-2 bg-[#4CAE4F] text-white px-5 py-2.5 rounded-xl hover:bg-[#439c47] transition-all shadow-lg shadow-green-200 hover:shadow-xl hover:-translate-y-0.5"
                    >
                        <FaPlus />
                        <span className="font-medium">Thêm mới</span>
                    </button>
                </div>
            </div>

            {/* Error Message */}
            {error && (
                <div className="bg-red-50 text-red-600 p-4 rounded-xl mb-6 border border-red-100 flex items-center">
                    <span className="font-medium mr-2">Lỗi:</span> {error}
                </div>
            )}

            {/* Content Section */}
            {loading ? (
                <div className="flex flex-col items-center justify-center py-20">
                    <div className="w-12 h-12 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                    <p className="text-gray-500 animate-pulse">Đang tải dữ liệu...</p>
                </div>
            ) : (
                <CategoryTable
                    categories={filteredCategories}
                    onEdit={handleOpenModal}
                    onDelete={handleDelete}
                    onToggleStatus={toggleCategoryStatus}
                />
            )}

            {/* Modal */}
            <CategoryModal
                isOpen={isModalOpen}
                onClose={handleCloseModal}
                onSubmit={handleSubmit}
                editingCategory={editingCategory}
                nextOrder={categories.length > 0 ? Math.max(...categories.map(c => c.order)) + 1 : 1}
            />
        </div>
    );
};

export default CategoriesManager;
