import React from 'react';
import { FaTimes, FaTag, FaLayerGroup, FaMoneyBillWave, FaInfoCircle, FaCheckCircle, FaTimesCircle, FaImage } from 'react-icons/fa';
import { getIconComponent } from "../../../constants/icons";

const ServiceDetailModal = ({ isOpen, onClose, service, categories }) => {
    if (!isOpen || !service) return null;

    const IconComp = getIconComponent(service.iconName);

    const getCategoryName = (catId) => {
        const cat = categories.find(c => c.id === catId);
        return cat ? cat.name : 'Chưa phân loại';
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] flex flex-col overflow-hidden transform transition-all scale-100">
                {/* Header */}
                <div className="flex justify-between items-center px-6 py-4 border-b border-gray-100 bg-gradient-to-r from-blue-50 to-white">
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center text-blue-600">
                            <FaInfoCircle size={20} />
                        </div>
                        <h2 className="text-xl font-bold text-gray-800">Chi tiết Dịch vụ</h2>
                    </div>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-red-500 hover:bg-red-50 p-2 rounded-full transition-all"
                    >
                        <FaTimes size={20} />
                    </button>
                </div>

                {/* Body */}
                <div className="p-6 overflow-y-auto space-y-6">
                    {/* Basic Info */}
                    <div className="flex items-start gap-4">
                        <div className="w-20 h-20 rounded-xl bg-gray-100 border border-gray-200 flex items-center justify-center flex-shrink-0 overflow-hidden">
                            {service.imageUrl ? (
                                <img src={service.imageUrl} alt={service.name} className="w-full h-full object-cover" />
                            ) : (
                                <IconComp size={40} className="text-gray-400" />
                            )}
                        </div>
                        <div className="flex-1">
                            <h3 className="text-2xl font-bold text-gray-900">{service.name}</h3>
                            <div className="flex items-center gap-2 mt-1">
                                <span className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium ${service.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                    {service.isActive ? <FaCheckCircle size={10} /> : <FaTimesCircle size={10} />}
                                    {service.isActive ? 'Đang hoạt động' : 'Đang ẩn'}
                                </span>
                                <span className="bg-gray-100 text-gray-600 px-2.5 py-0.5 rounded-full text-xs font-medium flex items-center gap-1">
                                    <FaLayerGroup size={10} />
                                    {getCategoryName(service.categoryId)}
                                </span>
                            </div>
                            <p className="mt-3 text-gray-600 text-sm leading-relaxed">
                                {service.description || 'Chưa có mô tả cho dịch vụ này.'}
                            </p>
                        </div>
                    </div>

                    {/* Pricing Info */}
                    <div className="bg-blue-50/50 rounded-xl p-5 border border-blue-100">
                        <h4 className="text-sm font-bold text-blue-800 uppercase tracking-wide mb-3 flex items-center gap-2">
                            <FaMoneyBillWave /> Bảng giá dịch vụ
                        </h4>
                        <div className="grid grid-cols-3 gap-4">
                            <div className="bg-white p-3 rounded-lg border border-blue-100 shadow-sm">
                                <span className="block text-xs text-gray-500 mb-1">Giá tối thiểu</span>
                                <span className="font-semibold text-gray-900">{formatCurrency(service.minPrice || 0)}</span>
                            </div>
                            <div className="bg-white p-3 rounded-lg border border-green-200 shadow-sm ring-1 ring-green-100">
                                <span className="block text-xs text-green-600 mb-1 font-medium">Giá gợi ý</span>
                                <span className="font-bold text-green-700 text-lg">{formatCurrency(service.suggestedPrice || 0)}</span>
                                <span className="text-xs text-gray-400 ml-1">/ {service.priceUnit}</span>
                            </div>
                            <div className="bg-white p-3 rounded-lg border border-blue-100 shadow-sm">
                                <span className="block text-xs text-gray-500 mb-1">Giá tối đa</span>
                                <span className="font-semibold text-gray-900">{formatCurrency(service.maxPrice || 0)}</span>
                            </div>
                        </div>
                    </div>

                    {/* Meta Info */}
                    <div className="grid grid-cols-2 gap-4 text-sm text-gray-500">
                        <div className="flex items-center gap-2">
                            <span className="w-24">Icon Name:</span>
                            <code className="bg-gray-100 px-2 py-1 rounded text-gray-700">{service.iconName}</code>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-24">Đơn vị:</span>
                            <span className="font-medium text-gray-700">{service.priceUnit}</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-24">Ngày tạo:</span>
                            <span className="font-medium text-gray-700">{service.createdAt?.toDate().toLocaleDateString('vi-VN')}</span>
                        </div>
                        <div className="flex items-center gap-2">
                            <span className="w-24">Cập nhật:</span>
                            <span className="font-medium text-gray-700">{service.updatedAt?.toDate().toLocaleDateString('vi-VN')}</span>
                        </div>
                    </div>
                </div>

                {/* Footer */}
                <div className="flex justify-end px-6 py-4 border-t border-gray-100 bg-gray-50">
                    <button
                        onClick={onClose}
                        className="px-6 py-2 bg-white border border-gray-300 hover:bg-gray-50 text-gray-700 rounded-xl font-medium shadow-sm transition-all"
                    >
                        Đóng
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ServiceDetailModal;
