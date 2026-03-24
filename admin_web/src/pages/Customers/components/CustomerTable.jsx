import React from 'react';

/**
 * Component hiển thị bảng danh sách khách hàng.
 */
const CustomerTable = ({
    customers,
    loading,
    onView,
    onEdit,
    onDelete,
    onToggleStatus,
    onCopyId,
    getInitials
}) => {
    return (
        <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Khách hàng</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Liên hệ</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Ngày tham gia</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Số đơn</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Trạng thái</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 text-right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200 dark:divide-slate-800">
                        {loading ? (
                            <tr>
                                <td colSpan="6" className="px-6 py-10 text-center text-slate-500">
                                    <div className="flex items-center justify-center gap-2">
                                        <div className="animate-spin size-5 border-2 border-green-500 border-t-transparent rounded-full"></div>
                                        Đang tải dữ liệu...
                                    </div>
                                </td>
                            </tr>
                        ) : customers.length === 0 ? (
                            <tr>
                                <td colSpan="6" className="px-6 py-10 text-center text-slate-500 font-medium">
                                    Không tìm thấy khách hàng nào.
                                </td>
                            </tr>
                        ) : (
                            customers.map((customer) => (
                                <tr key={customer.id} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/30 transition-colors group">
                                    {/* Khách hàng */}
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {customer.photoURL || customer.avatarUrl || customer.avatar || customer.avatar_url ? (
                                                <img
                                                    className="size-10 rounded-full object-cover shadow-sm border border-slate-100 dark:border-slate-700"
                                                    src={customer.photoURL || customer.avatarUrl || customer.avatar || customer.avatar_url}
                                                    alt=""
                                                    onError={(e) => {
                                                        e.target.style.display = 'none';
                                                        e.target.nextSibling.style.display = 'flex';
                                                    }}
                                                />
                                            ) : null}
                                            <div
                                                className="size-10 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center font-bold text-green-700 dark:text-green-400 border border-green-200/50 dark:border-green-800/50"
                                                style={{ display: (customer.photoURL || customer.avatarUrl || customer.avatar || customer.avatar_url) ? 'none' : 'flex' }}
                                            >
                                                {getInitials(customer.full_name || customer.name || customer.displayName)}
                                            </div>
                                            <div>
                                                <p className="text-sm font-semibold text-slate-900 dark:text-white truncate max-w-[150px]">
                                                    {customer.full_name || customer.name || customer.displayName || 'Khách hàng'}
                                                </p>
                                                <div className="flex items-center gap-1 group/id mt-0.5">
                                                    <p className="text-[10px] text-slate-400 font-mono" title={customer.id}>
                                                        ID: {customer.id.slice(0, 8)}...
                                                    </p>
                                                    <button
                                                        onClick={() => onCopyId(customer.id)}
                                                        className="text-slate-400 hover:text-green-600 opacity-0 group-hover/id:opacity-100 transition-all"
                                                        title="Sao chép ID"
                                                    >
                                                        <span className="material-symbols-outlined text-[12px]">content_copy</span>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    {/* Liên hệ */}
                                    <td className="px-6 py-4">
                                        <p className="text-sm font-medium text-slate-700 dark:text-slate-300">{customer.phoneNumber || customer.phone || '---'}</p>
                                        <p className="text-xs text-slate-500 truncate max-w-[180px]">{customer.email || '---'}</p>
                                    </td>

                                    {/* Ngày tham gia */}
                                    <td className="px-6 py-4">
                                        <p className="text-sm text-slate-600 dark:text-slate-400 font-medium">
                                            {customer.createdAt ? new Date(customer.createdAt).toLocaleDateString('vi-VN') : '---'}
                                        </p>
                                    </td>

                                    {/* Số đơn */}
                                    <td className="px-6 py-4">
                                        <span className="inline-flex items-center justify-center bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 rounded-full px-2.5 py-0.5 text-xs font-bold border border-slate-200 dark:border-slate-700">
                                            {customer.orderCount || 0}
                                        </span>
                                    </td>

                                    {/* Trạng thái */}
                                    <td className="px-6 py-4">
                                        {customer.isActive !== false ? (
                                            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-green-50 text-green-600 border border-green-100 dark:bg-green-900/20 dark:border-green-800/50">
                                                <span className="size-1.5 rounded-full bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.4)]"></span>
                                                Hoạt động
                                            </span>
                                        ) : (
                                            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-red-50 text-red-600 border border-red-100 dark:bg-red-900/20 dark:border-red-800/50">
                                                <span className="size-1.5 rounded-full bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.4)]"></span>
                                                Bị khóa
                                            </span>
                                        )}
                                    </td>

                                    {/* Thao tác */}
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-1.5">
                                            <button
                                                onClick={() => onView(customer)}
                                                className="p-1.5 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-400 hover:text-green-600 transition-all active:scale-90"
                                                title="Xem chi tiết"
                                            >
                                                <span className="material-symbols-outlined text-[20px]">visibility</span>
                                            </button>
                                            
                                            <button
                                                onClick={() => onToggleStatus(customer.id, customer.isActive)}
                                                className={`p-1.5 rounded-lg text-slate-400 transition-all active:scale-90 ${customer.isActive !== false ? 'hover:bg-amber-50 hover:text-amber-600' : 'hover:bg-green-50 hover:text-green-600'}`}
                                                title={customer.isActive !== false ? "Khóa tài khoản" : "Mở khóa"}
                                            >
                                                <span className="material-symbols-outlined text-[20px]">
                                                    {customer.isActive !== false ? 'lock_open' : 'lock'}
                                                </span>
                                            </button>

                                            <button
                                                onClick={() => onEdit(customer)}
                                                className="p-1.5 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg text-slate-400 hover:text-blue-600 transition-all active:scale-90"
                                                title="Chỉnh sửa"
                                            >
                                                <span className="material-symbols-outlined text-[20px]">edit</span>
                                            </button>

                                            <button
                                                onClick={() => onDelete(customer.id)}
                                                className="p-1.5 hover:bg-red-50 dark:hover:bg-red-900/30 rounded-lg text-slate-400 hover:text-red-600 transition-all active:scale-90"
                                                title="Xóa"
                                            >
                                                <span className="material-symbols-outlined text-[20px]">delete</span>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default CustomerTable;
