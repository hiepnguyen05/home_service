import React from 'react';
import { getIconComponent } from "../../../constants/icons";
import { FaEdit, FaTrash, FaToggleOn, FaToggleOff, FaEye } from 'react-icons/fa';

const ServiceTable = ({ services, categories, onEdit, onDelete, onToggleStatus, onView }) => {

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    };

    const getCategoryName = (catId) => {
        const cat = categories.find(c => c.id === catId);
        return cat ? cat.name : 'Chưa phân loại';
    };

    return (
        <div className="overflow-x-auto">
            <table className="w-full text-sm text-left">
                <thead className="text-xs text-gray-500 uppercase bg-gray-50 border-b border-gray-100">
                    <tr>
                        <th className="px-6 py-4">Tên Dịch vụ</th>
                        <th className="px-6 py-4">Danh mục</th>
                        <th className="px-6 py-4">Chi phí</th>
                        <th className="px-6 py-4 text-center">Icon</th>
                        <th className="px-6 py-4 text-center">Trạng thái</th>
                        <th className="px-6 py-4 text-center">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    {services.length === 0 ? (
                        <tr>
                            <td colSpan="6" className="text-center py-8 text-gray-500">
                                Không tìm thấy dịch vụ nào.
                            </td>
                        </tr>
                    ) : (
                        services.map((service) => {
                            const IconComp = getIconComponent(service.iconName);
                            return (
                                <tr key={service.id} className="border-b border-gray-50 hover:bg-green-50/30 transition-colors duration-200 group">
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {service.imageUrl ? (
                                                <img
                                                    src={service.imageUrl}
                                                    alt={service.name}
                                                    className="w-10 h-10 rounded-lg object-cover bg-gray-100 border border-gray-200"
                                                />
                                            ) : (
                                                <div className="w-10 h-10 rounded-lg bg-green-50 text-[#4CAE4F] flex items-center justify-center font-bold text-lg">
                                                    {service.name.charAt(0).toUpperCase()}
                                                </div>
                                            )}
                                            <div>
                                                <div className="font-semibold text-gray-900">{service.name}</div>
                                                <div className="text-xs text-gray-500 truncate max-w-[200px]" title={service.description}>
                                                    {service.description}
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4">
                                        <span className="bg-gray-100 text-gray-700 px-2.5 py-1 rounded-md text-xs font-medium border border-gray-200">
                                            {getCategoryName(service.categoryId)}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex flex-col">
                                            <span className="font-bold text-[#4CAE4F]">
                                                {formatCurrency(service.suggestedPrice || 0)}
                                                <span className="text-gray-500 font-normal text-xs ml-1">/ {service.priceUnit}</span>
                                            </span>
                                            <span className="text-xs text-gray-400 mt-0.5">
                                                {formatCurrency(service.minPrice || 0)} - {formatCurrency(service.maxPrice || 0)}
                                            </span>
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <div className="w-8 h-8 mx-auto rounded-full bg-gray-50 flex items-center justify-center text-gray-500 group-hover:text-[#4CAE4F] group-hover:bg-green-50 transition-colors">
                                            <IconComp size={18} />
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <button
                                            onClick={() => onToggleStatus(service)}
                                            className={`relative inline-flex items-center justify-center w-10 h-5 rounded-full transition-colors focus:outline-none ${service.isActive ? 'bg-[#4CAE4F]' : 'bg-gray-300'}`}
                                        >
                                            <span className={`absolute left-0.5 w-4 h-4 rounded-full bg-white transition-transform transform ${service.isActive ? 'translate-x-5' : 'translate-x-0'}`} />
                                        </button>
                                    </td>
                                    <td className="px-6 py-4 text-center">
                                        <div className="flex items-center justify-center gap-2">
                                            <button
                                                onClick={() => onView(service)}
                                                className="p-1.5 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                                                title="Xem chi tiết"
                                            >
                                                <FaEye size={16} />
                                            </button>
                                            <button
                                                onClick={() => onEdit(service)}
                                                className="p-1.5 text-gray-500 hover:text-orange-600 hover:bg-orange-50 rounded-lg transition-colors"
                                                title="Chỉnh sửa"
                                            >
                                                <FaEdit size={16} />
                                            </button>
                                            <button
                                                onClick={() => onDelete(service.id)}
                                                className="p-1.5 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                                                title="Xóa"
                                            >
                                                <FaTrash size={16} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            );
                        })
                    )}
                </tbody>
            </table>
        </div>
    );
};

export default ServiceTable;
