import React from 'react';
import { FaEdit, FaTrash, FaToggleOn, FaToggleOff, FaImage } from 'react-icons/fa';

const StatusBadge = ({ isActive }) => (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider ${isActive ? 'bg-green-100 text-green-700' : 'bg-slate-100 text-slate-500'}`}>
        <span className={`w-1.5 h-1.5 mr-1.5 rounded-full ${isActive ? 'bg-green-500 animate-pulse' : 'bg-slate-400'}`}></span>
        {isActive ? 'Đang hiển thị' : 'Đã ẩn'}
    </span>
);

const BannerTable = ({ banners, onEdit, onDelete, onToggleStatus }) => {
    if (!banners || banners.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center py-24 bg-white dark:bg-slate-800 rounded-3xl border border-dashed border-slate-200 dark:border-slate-700">
                <div className="w-20 h-20 rounded-full bg-slate-50 dark:bg-slate-900 flex items-center justify-center mb-4">
                    <FaImage className="text-slate-300 text-3xl" />
                </div>
                <h3 className="text-lg font-bold text-slate-800 dark:text-slate-200">Kho banner trống</h3>
                <p className="text-slate-500 text-sm mt-1">Hãy bắt đầu bằng cách thêm banner đầu tiên!</p>
            </div>
        );
    }

    return (
        <div className="bg-white dark:bg-slate-800 rounded-3xl shadow-xl shadow-slate-200/50 dark:shadow-none border border-slate-100 dark:border-slate-800 overflow-hidden">
            <div className="overflow-x-auto">
                <table className="w-full text-left border-separate border-spacing-0">
                    <thead className="bg-slate-50/50 dark:bg-slate-900/50 text-slate-500 dark:text-slate-400 text-[11px] uppercase font-black tracking-widest">
                        <tr>
                            <th className="px-8 py-5 border-b border-slate-100 dark:border-slate-800 w-24 text-center">Thứ tự</th>
                            <th className="px-8 py-5 border-b border-slate-100 dark:border-slate-800">Hình ảnh quảng cáo</th>
                            <th className="px-8 py-5 border-b border-slate-100 dark:border-slate-800 w-44">Trạng thái áp dụng</th>
                            <th className="px-8 py-5 border-b border-slate-100 dark:border-slate-800 w-40 text-center">Hành động</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-50 dark:divide-slate-800">
                        {banners.map((banner) => (
                            <tr key={banner.id} className="hover:bg-slate-50/30 dark:hover:bg-slate-800/30 transition-all group">
                                <td className="px-8 py-6">
                                    <div className="w-10 h-10 rounded-xl bg-slate-100 dark:bg-slate-900 flex items-center justify-center mx-auto">
                                        <span className="text-sm font-black text-slate-700 dark:text-slate-300">#{banner.order}</span>
                                    </div>
                                </td>
                                <td className="px-8 py-6">
                                    <div className="relative w-64 aspect-[2/1] rounded-2xl overflow-hidden border-2 border-slate-100 dark:border-slate-800 shadow-sm transition-all group-hover:shadow-md group-hover:scale-[1.01] group-hover:border-[#4CAE4F]/30 bg-slate-100">
                                        <img 
                                            src={banner.imageUrl} 
                                            alt="Banner Content" 
                                            className="w-full h-full object-cover"
                                            onError={(e) => { e.target.src = 'https://placehold.co/1200x600?text=Lỗi+đường+dẫn+ảnh'; }}
                                        />
                                    </div>
                                </td>
                                <td className="px-8 py-6">
                                    <StatusBadge isActive={banner.isActive} />
                                </td>
                                <td className="px-8 py-6">
                                    <div className="flex justify-center items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button
                                            onClick={() => onToggleStatus(banner)}
                                            className={`p-2.5 rounded-xl transition-all shadow-sm ${banner.isActive ? 'bg-green-50 text-green-600 hover:bg-green-100' : 'bg-slate-100 text-slate-400 hover:bg-slate-200'}`}
                                            title={banner.isActive ? "Tắt banner" : "Bật banner"}
                                        >
                                            {banner.isActive ? <FaToggleOn size={24} /> : <FaToggleOff size={24} />}
                                        </button>
                                        <div className="w-px h-6 bg-slate-200 dark:bg-slate-700 mx-1"></div>
                                        <button
                                            onClick={() => onEdit(banner)}
                                            className="bg-blue-50 text-blue-600 p-2.5 rounded-xl hover:bg-blue-100 transition-all shadow-sm"
                                            title="Sửa"
                                        >
                                            <FaEdit size={18} />
                                        </button>
                                        <button
                                            onClick={() => onDelete(banner.id, "banner này")}
                                            className="bg-red-50 text-red-500 p-2.5 rounded-xl hover:bg-red-100 transition-all shadow-sm"
                                            title="Xóa"
                                        >
                                            <FaTrash size={18} />
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default BannerTable;
