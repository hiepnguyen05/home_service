import React, { useState, useEffect } from 'react';
import { FaTimes, FaSave, FaCheck, FaLayerGroup, FaTags, FaDollarSign, FaImage, FaAlignLeft, FaCube, FaCloudUploadAlt, FaSpinner } from 'react-icons/fa';
import IconPicker from '../../../components/Form/IconPicker';
import { uploadToCloudinary } from '../../../utils/cloudinaryUtils';

const ServiceModal = ({ isOpen, onClose, onSubmit, editingService, categories }) => {
    const [isUploading, setIsUploading] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        categoryId: '',
        description: '',
        minPrice: '',
        maxPrice: '',
        suggestedPrice: '',
        priceUnit: 'lần',
        iconName: 'cleaning_services',
        imageUrl: '',
        isActive: true
    });

    useEffect(() => {
        if (isOpen) {
            if (editingService) {
                setFormData({
                    name: editingService.name || '',
                    categoryId: editingService.categoryId || '',
                    description: editingService.description || '',
                    minPrice: editingService.minPrice || '',
                    maxPrice: editingService.maxPrice || '',
                    suggestedPrice: editingService.suggestedPrice || '',
                    priceUnit: editingService.priceUnit || 'lần',
                    iconName: editingService.iconName || 'cleaning_services',
                    imageUrl: editingService.imageUrl || '',
                    isActive: editingService.isActive !== undefined ? editingService.isActive : true
                });
            } else {
                setFormData({
                    name: '',
                    categoryId: categories.length > 0 ? categories[0].id : '',
                    description: '',
                    minPrice: '',
                    maxPrice: '',
                    suggestedPrice: '',
                    priceUnit: 'lần',
                    iconName: 'cleaning_services',
                    imageUrl: '',
                    isActive: true
                });
            }
        }
    }, [isOpen, editingService, categories]);

    const handleFileChange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        setIsUploading(true);
        try {
            const url = await uploadToCloudinary(file);
            setFormData(prev => ({ ...prev, imageUrl: url }));
        } catch (error) {
            alert('Upload ảnh thất bại: ' + error.message);
        } finally {
            setIsUploading(false);
        }
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden transform transition-all scale-100">
                {/* Header */}
                <div className="flex justify-between items-center px-6 py-4 border-b border-gray-100 bg-gradient-to-r from-green-50 to-white flex-shrink-0">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center text-[#4CAE4F]">
                            <FaTags size={20} />
                        </div>
                        <h2 className="text-xl font-bold text-gray-800">
                            {editingService ? 'Cập nhật Dịch vụ' : 'Thêm Dịch vụ mới'}
                        </h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-red-500 hover:bg-red-50 p-2 rounded-full transition-all"
                    >
                        <FaTimes size={20} />
                    </button>
                </div>

                {/* Body - Scrollable */}
                <div className="p-6 overflow-y-auto flex-1">
                    <form id="serviceForm" onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        {/* Left Column */}
                        <div className="space-y-5">
                            {/* Name Input */}
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Tên dịch vụ <span className="text-red-500">*</span>
                                </label>
                                <div className="relative">
                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
                                        <FaCube />
                                    </div>
                                    <input
                                        type="text"
                                        required
                                        className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/50 focus:border-[#4CAE4F] outline-none transition-all placeholder-gray-400"
                                        value={formData.name}
                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                        placeholder="Ví dụ: Dọn nhà theo giờ"
                                    />
                                </div>
                            </div>

                            {/* Category Select */}
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Danh mục <span className="text-red-500">*</span>
                                </label>
                                <div className="relative">
                                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-gray-400">
                                        <FaLayerGroup />
                                    </div>
                                    <select
                                        required
                                        className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/50 focus:border-[#4CAE4F] outline-none transition-all appearance-none bg-white"
                                        value={formData.categoryId}
                                        onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                                    >
                                        <option value="">-- Chọn danh mục --</option>
                                        {categories.map(cat => (
                                            <option key={cat.id} value={cat.id}>{cat.name}</option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            {/* Icon Picker */}
                            <div className="bg-gray-50 p-4 rounded-xl border border-gray-200">
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Chọn Biểu tượng</label>
                                <IconPicker
                                    selectedIcon={formData.iconName}
                                    onSelect={(name) => setFormData({ ...formData, iconName: name })}
                                />
                            </div>

                            {/* Image Upload */}
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">Ảnh bìa</label>
                                <div className="flex items-start gap-4 p-4 border border-gray-200 rounded-xl bg-gray-50/50">
                                    {/* Preview Area */}
                                    <div className="relative w-32 h-32 flex-shrink-0">
                                        {formData.imageUrl ? (
                                            <div className="w-full h-full rounded-lg overflow-hidden border border-gray-200 group relative shadow-sm">
                                                <img
                                                    src={formData.imageUrl}
                                                    alt="Preview"
                                                    className="w-full h-full object-cover"
                                                />
                                                <button
                                                    type="button"
                                                    onClick={() => setFormData({ ...formData, imageUrl: '' })}
                                                    className="absolute top-1 right-1 bg-white/90 text-red-500 p-1.5 rounded-full shadow-sm opacity-0 group-hover:opacity-100 transition-all hover:bg-red-50"
                                                    title="Xóa ảnh"
                                                >
                                                    <FaTimes size={12} />
                                                </button>
                                            </div>
                                        ) : (
                                            <div className="w-full h-full rounded-lg border-2 border-dashed border-gray-300 flex flex-col items-center justify-center text-gray-400 bg-white">
                                                {isUploading ? (
                                                    <FaSpinner className="animate-spin text-2xl mb-2 text-[#4CAE4F]" />
                                                ) : (
                                                    <FaImage className="text-3xl mb-2 opacity-50" />
                                                )}
                                                <span className="text-xs font-medium">{isUploading ? 'Đang tải...' : 'Chưa có ảnh'}</span>
                                            </div>
                                        )}
                                    </div>

                                    {/* Upload Controls */}
                                    <div className="flex-1 pt-1">
                                        <input
                                            type="file"
                                            id="imageUpload"
                                            className="hidden"
                                            accept="image/*"
                                            onChange={handleFileChange}
                                            disabled={isUploading}
                                        />
                                        <label
                                            htmlFor="imageUpload"
                                            className={`inline-flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all shadow-sm cursor-pointer border ${isUploading
                                                ? 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed'
                                                : 'bg-white text-gray-700 border-gray-300 hover:bg-gray-50 hover:border-gray-400'
                                                }`}
                                        >
                                            <FaCloudUploadAlt size={18} className={isUploading ? '' : 'text-[#4CAE4F]'} />
                                            {isUploading ? 'Đang xử lý...' : (formData.imageUrl ? 'Thay đổi ảnh khác' : 'Tải ảnh lên')}
                                        </label>
                                        <p className="text-xs text-gray-500 mt-3 leading-relaxed">
                                            Hỗ trợ định dạng JPG, PNG, WEBP.<br />
                                            Ảnh sẽ được lưu trữ tự động trên Cloudinary.
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Right Column */}
                        <div className="space-y-5">
                            {/* Pricing Section */}
                            <div className="bg-blue-50/50 p-4 rounded-xl border border-blue-100 space-y-4">
                                <h3 className="text-sm font-bold text-blue-800 flex items-center gap-2">
                                    <FaDollarSign /> Thông tin giá cả
                                </h3>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-600 mb-1">Giá gợi ý (VNĐ) <span className="text-red-500">*</span></label>
                                        <input
                                            type="number"
                                            required
                                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 outline-none transition-all"
                                            value={formData.suggestedPrice}
                                            onChange={(e) => setFormData({ ...formData, suggestedPrice: e.target.value })}
                                            placeholder="VD: 100000"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-600 mb-1">Đơn vị tính</label>
                                        <select
                                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 outline-none transition-all bg-white"
                                            value={formData.priceUnit}
                                            onChange={(e) => setFormData({ ...formData, priceUnit: e.target.value })}
                                        >
                                            <option value="lần">Lần</option>
                                            <option value="giờ">Giờ</option>
                                            <option value="m²">m²</option>
                                            <option value="cái">Cái</option>
                                            <option value="bộ">Bộ</option>
                                            <option value="km">Km</option>
                                            <option value="kg">Kg</option>
                                        </select>
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-600 mb-1">Giá tối thiểu</label>
                                        <input
                                            type="number"
                                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 outline-none transition-all"
                                            value={formData.minPrice}
                                            onChange={(e) => setFormData({ ...formData, minPrice: e.target.value })}
                                            placeholder="Sàn"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs font-semibold text-gray-600 mb-1">Giá tối đa</label>
                                        <input
                                            type="number"
                                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500/30 focus:border-blue-500 outline-none transition-all"
                                            value={formData.maxPrice}
                                            onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value })}
                                            placeholder="Trần"
                                        />
                                    </div>
                                </div>
                            </div>

                            {/* Description */}
                            <div>
                                <label className="block text-sm font-semibold text-gray-700 mb-2">
                                    Mô tả ngắn
                                </label>
                                <div className="relative">
                                    <div className="absolute top-3 left-3 flex items-start pointer-events-none text-gray-400">
                                        <FaAlignLeft />
                                    </div>
                                    <textarea
                                        rows="4"
                                        className="w-full pl-10 pr-4 py-2.5 border border-gray-300 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/50 focus:border-[#4CAE4F] outline-none transition-all placeholder-gray-400 resize-none"
                                        value={formData.description}
                                        onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                        placeholder="Mô tả ngắn gọn về dịch vụ này..."
                                    ></textarea>
                                </div>
                            </div>

                            {/* Status */}
                            <div className="flex items-center p-4 rounded-xl border border-gray-200 hover:bg-gray-50 transition w-full cursor-pointer" onClick={() => setFormData({ ...formData, isActive: !formData.isActive })}>
                                <div className={`w-6 h-6 rounded border flex items-center justify-center mr-3 transition-colors ${formData.isActive ? 'bg-[#4CAE4F] border-[#4CAE4F]' : 'bg-white border-gray-300'}`}>
                                    {formData.isActive && <FaCheck className="text-white text-xs" />}
                                </div>
                                <div className="flex-1">
                                    <span className="text-sm font-semibold text-gray-800 block">Kích hoạt dịch vụ</span>
                                    <span className="text-xs text-gray-500">Dịch vụ sẽ hiển thị trên ứng dụng khách hàng</span>
                                </div>
                                <div className={`w-10 h-5 rounded-full relative transition-colors ${formData.isActive ? 'bg-[#4CAE4F]' : 'bg-gray-300'}`}>
                                    <div className={`absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full transition-transform ${formData.isActive ? 'translate-x-5' : 'translate-x-0'}`}></div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                {/* Footer */}
                <div className="flex justify-end gap-3 px-6 py-4 border-t border-gray-100 bg-gray-50 flex-shrink-0">
                    <button
                        type="button"
                        onClick={onClose}
                        className="px-5 py-2.5 text-gray-600 hover:bg-gray-100 rounded-xl font-medium transition-colors"
                    >
                        Hủy bỏ
                    </button>
                    <button
                        type="submit"
                        form="serviceForm"
                        className="px-6 py-2.5 bg-[#4CAE4F] hover:bg-[#439c47] text-white rounded-xl font-medium shadow-lg shadow-green-200 flex items-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98]"
                    >
                        <FaCheck />
                        {editingService ? 'Lưu cập nhật' : 'Tạo mới'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ServiceModal;
