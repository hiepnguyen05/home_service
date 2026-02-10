import React, { useState, useEffect } from 'react';
import { FaTimes, FaSave, FaCheck, FaLayerGroup } from 'react-icons/fa';
import IconPicker from '../../../components/Form/IconPicker';

const CategoryModal = ({ isOpen, onClose, onSubmit, editingCategory, nextOrder }) => {
    const [formData, setFormData] = useState({
        name: '',
        iconName: 'cleaning_services',
        order: 1,
        isActive: true
    });

    useEffect(() => {
        if (isOpen) {
            if (editingCategory) {
                setFormData({
                    name: editingCategory.name || '',
                    iconName: editingCategory.iconName || 'cleaning_services',
                    order: editingCategory.order || 1,
                    isActive: editingCategory.isActive ?? true
                });
            } else {
                setFormData({
                    name: '',
                    iconName: 'cleaning_services',
                    order: nextOrder || 1,
                    isActive: true
                });
            }
        }
    }, [isOpen, editingCategory, nextOrder]);

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden transform transition-all scale-100">
                {/* Header */}
                <div className="flex justify-between items-center px-6 py-4 border-b border-gray-100 bg-gradient-to-r from-green-50 to-white">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-[#4CAE4F]">
                            <FaLayerGroup size={20} />
                        </div>
                        <h2 className="text-xl font-bold text-gray-800">
                            {editingCategory ? 'Chỉnh sửa Danh mục' : 'Thêm Danh mục mới'}
                        </h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-red-500 hover:bg-red-50 p-2 rounded-full transition-all"
                    >
                        <FaTimes size={20} />
                    </button>
                </div>

                {/* Body */}
                <div className="p-6">
                    <form onSubmit={handleSubmit} className="flex flex-col gap-5">
                        {/* Name Input */}
                        <div>
                            <label className="block text-sm font-semibold text-gray-700 mb-2">
                                Tên danh mục <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="text"
                                required
                                className="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/50 focus:border-[#4CAE4F] outline-none transition-all placeholder-gray-400"
                                value={formData.name}
                                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                placeholder="Nhập tên danh mục..."
                            />
                        </div>

                        {/* Icon Picker */}
                        <div className="bg-gray-50 p-4 rounded-xl border border-gray-200">
                            <label className="block text-sm font-semibold text-gray-700 mb-2">Chọn Biểu tượng</label>
                            <IconPicker
                                selectedIcon={formData.iconName}
                                onSelect={(name) => setFormData({ ...formData, iconName: name })}
                            />
                        </div>

                        {/* Order & Status */}
                        <div className="grid grid-cols-2 gap-5">
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Thứ tự hiển thị</label>
                                <input
                                    type="number"
                                    required
                                    min="0"
                                    className="w-full px-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/50 outline-none transition-all"
                                    value={formData.order}
                                    onChange={(e) => setFormData({ ...formData, order: parseInt(e.target.value) || 0 })}
                                />
                            </div>

                            <div className="flex items-end">
                                <label className="relative flex items-center p-3 rounded-xl border border-gray-200 cursor-pointer hover:bg-gray-50 transition w-full">
                                    <input
                                        type="checkbox"
                                        className="w-5 h-5 text-[#4CAE4F] rounded focus:ring-[#4CAE4F] border-gray-300 mr-3 accent-[#4CAE4F]"
                                        checked={formData.isActive}
                                        onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                                    />
                                    <span className="text-sm font-medium text-gray-700 select-none">
                                        Đang hoạt động
                                    </span>
                                </label>
                            </div>
                        </div>

                        {/* Footer Buttons */}
                        <div className="flex justify-end gap-3 mt-4 pt-4 border-t border-gray-100">
                            <button
                                type="button"
                                onClick={onClose}
                                className="px-5 py-2.5 text-gray-600 hover:bg-gray-100 rounded-xl font-medium transition-colors"
                            >
                                Hủy bỏ
                            </button>
                            <button
                                type="submit"
                                className="px-6 py-2.5 bg-[#4CAE4F] hover:bg-[#439c47] text-white rounded-xl font-medium shadow-lg shadow-green-200 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]"
                            >
                                <FaCheck />
                                {editingCategory ? 'Cập nhật' : 'Lưu lại'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
};

export default CategoryModal;
