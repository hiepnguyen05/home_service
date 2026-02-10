import React from 'react';
import { FaEdit, FaTrash, FaToggleOn, FaToggleOff } from 'react-icons/fa';
import { getIconComponent } from '../../../constants/icons';
import StatusBadge from './StatusBadge';

const CategoryTable = ({ categories, onEdit, onDelete, onToggleStatus }) => {
    if (!categories || categories.length === 0) {
        return (
            <div className="text-center py-10 bg-white rounded-xl border border-dashed border-gray-300">
                <p className="text-gray-500">Chưa có danh mục nào. Hãy thêm danh mục mới!</p>
            </div>
        );
    }

    return (
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead className="bg-gray-50 text-gray-700 text-xs uppercase font-semibold">
                        <tr>
                            <th className="px-6 py-4 border-b border-gray-200">Thứ tự</th>
                            <th className="px-6 py-4 border-b border-gray-200">Icon</th>
                            <th className="px-6 py-4 border-b border-gray-200">Tên danh mục</th>
                            <th className="px-6 py-4 border-b border-gray-200">Mã Icon</th>
                            <th className="px-6 py-4 border-b border-gray-200">Trạng thái</th>
                            <th className="px-6 py-4 border-b border-gray-200 text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {categories.map((cat) => {
                            const IconComp = getIconComponent(cat.iconName);
                            return (
                                <tr key={cat.id} className="hover:bg-green-50/50 transition-colors duration-200 group">
                                    <td className="px-6 py-4 text-sm text-gray-600 font-medium">#{cat.order}</td>
                                    <td className="px-6 py-4">
                                        <div className="w-10 h-10 rounded-lg bg-[#4CAE4F]/10 text-[#4CAE4F] flex items-center justify-center shadow-sm group-hover:scale-110 transition-transform">
                                            <IconComp size={22} />
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 font-semibold text-gray-800">{cat.name}</td>
                                    <td className="px-6 py-4 font-mono text-xs text-gray-500 bg-gray-50 rounded px-2 w-fit">{cat.iconName}</td>
                                    <td className="px-6 py-4">
                                        <StatusBadge isActive={cat.isActive} />
                                    </td>
                                    <td className="px-6 py-4">
                                        <div className="flex justify-center gap-2">
                                            <button
                                                onClick={() => onToggleStatus(cat)}
                                                className={`p-2 rounded-lg transition-colors ${cat.isActive ? 'text-green-600 hover:bg-green-50' : 'text-gray-400 hover:bg-gray-100'}`}
                                                title={cat.isActive ? "Tạm ngưng" : "Kích hoạt"}
                                            >
                                                {cat.isActive ? <FaToggleOn size={20} /> : <FaToggleOff size={20} />}
                                            </button>
                                            <button
                                                onClick={() => onEdit(cat)}
                                                className="text-blue-500 hover:text-blue-700 p-2 hover:bg-blue-50 rounded-lg transition-colors"
                                                title="Chỉnh sửa"
                                            >
                                                <FaEdit size={18} />
                                            </button>
                                            <button
                                                onClick={() => onDelete(cat.id, cat.name)}
                                                className="text-red-500 hover:text-red-700 p-2 hover:bg-red-50 rounded-lg transition-colors"
                                                title="Xóa"
                                            >
                                                <FaTrash size={18} />
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            )
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default CategoryTable;
