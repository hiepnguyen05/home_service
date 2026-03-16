import React from 'react';

/**
 * Component hiển thị bảng danh sách nhà cung cấp.
 * 
 * @component
 * @param {Object} props
 * @param {Array} props.providers - Danh sách nhà cung cấp đã phân trang.
 * @param {boolean} props.loading - Trạng thái đang tải dữ liệu.
 * @param {Object} props.serviceCategoryMap - Map ánh xạ serviceId sang tên danh mục.
 * @param {string} props.activeTab - Tab hiện tại đang xem.
 * @param {Function} props.onView - Handler xem chi tiết.
 * @param {Function} props.onApprove - Handler duyệt.
 * @param {Function} props.onReject - Handler từ chối.
 * @param {Function} props.onToggleStatus - Handler khóa/mở khóa.
 * @param {Function} props.onEdit - Handler chỉnh sửa.
 * @param {Function} props.onDelete - Handler xóa.
 * @param {Function} props.onCopyId - Handler copy ID.
 * @param {Function} props.getInitials - Hàm lấy chữ cái đầu của tên.
 */
const ProviderTable = ({
    providers,
    loading,
    serviceCategoryMap,
    serviceMap, // Add serviceMap
    activeTab,
    onView,
    onApprove,
    onReject,
    onToggleStatus,
    onEdit,
    onDelete,
    onCopyId,
    getInitials
}) => {
    return (
        <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                    <thead>
                        <tr className="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Thông tin thợ</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Liên hệ</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Trạng thái</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Dịch vụ</th>
                            <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 text-right">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-200 dark:divide-slate-800">
                        {loading ? (
                            <tr>
                                <td colSpan="5" className="px-6 py-10 text-center text-slate-500">
                                    <div className="flex items-center justify-center gap-2">
                                        <div className="animate-spin size-5 border-2 border-green-500 border-t-transparent rounded-full"></div>
                                        Đang tải dữ liệu...
                                    </div>
                                </td>
                            </tr>
                        ) : providers.length === 0 ? (
                            <tr>
                                <td colSpan="5" className="px-6 py-10 text-center text-slate-500">
                                    Không tìm thấy thợ nào trong mục này.
                                </td>
                            </tr>
                        ) : (
                            providers.map((provider) => (
                                <tr key={provider.id} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/30 transition-colors group">
                                    {/* Cột Thông tin thợ */}
                                    <td className="px-6 py-4">
                                        <div className="flex items-center gap-3">
                                            {provider.avatar_url || provider.avatarUrl || provider.photoURL ? (
                                                <img
                                                    className="size-10 rounded-full object-cover"
                                                    src={provider.avatar_url || provider.avatarUrl || provider.photoURL}
                                                    alt=""
                                                    onError={(e) => {
                                                        e.target.style.display = 'none';
                                                        e.target.nextSibling.style.display = 'flex';
                                                    }}
                                                />
                                            ) : null}
                                            <div
                                                className="size-10 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center font-bold text-blue-700 dark:text-blue-400"
                                                style={{ display: provider.avatar_url || provider.avatarUrl || provider.photoURL ? 'none' : 'flex' }}
                                            >
                                                {getInitials(provider.full_name || provider.name || provider.displayName)}
                                            </div>
                                            <div>
                                                <p className="text-sm font-semibold">{provider.full_name || provider.name || provider.displayName || 'Chưa cập nhật'}</p>
                                                {activeTab === 'pending' && (
                                                    <span className={`inline-block px-1.5 py-0.5 mt-0.5 rounded text-[10px] font-bold uppercase ${
                                                        provider.requestType === 'update' 
                                                        ? 'bg-blue-100 text-blue-700 border border-blue-200' 
                                                        : 'bg-green-100 text-green-700 border border-green-200'
                                                    }`}>
                                                        {provider.requestType === 'update' ? 'Cập nhật' : 'Đăng ký'}
                                                    </span>
                                                )}
                                                <div className="flex items-center gap-1 group/id mt-0.5">
                                                    <p className="text-xs text-slate-500 font-mono" title={provider.id}>
                                                        ID: {provider.id.slice(0, 8)}...
                                                    </p>
                                                    <button
                                                        onClick={() => onCopyId(provider.id)}
                                                        className="text-slate-400 hover:text-green-600 opacity-0 group-hover/id:opacity-100 transition-all"
                                                        title="Sao chép ID"
                                                    >
                                                        <span className="material-symbols-outlined text-[14px]">content_copy</span>
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                    </td>

                                    {/* Cột Liên hệ */}
                                    <td className="px-6 py-4">
                                        <p className="text-sm">{provider.phoneNumber || provider.phone || '---'}</p>
                                        <p className="text-xs text-slate-500">{provider.email || '---'}</p>
                                    </td>

                                    {/* Cột Trạng thái */}
                                    <td className="px-6 py-4">
                                        <div className="flex flex-col gap-1 items-start">
                                            {provider.verificationStatus === 'rejected' ? (
                                                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                                                    <span className="material-symbols-outlined text-[14px]">cancel</span> Đã từ chối
                                                </span>
                                            ) : provider.isVerified || provider.verificationStatus === 'verified' ? (
                                                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                                                    <span className="material-symbols-outlined text-[14px]">verified</span> Đã duyệt
                                                </span>
                                            ) : (
                                                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-amber-100 text-amber-800">
                                                    Chờ duyệt
                                                </span>
                                            )}

                                            {provider.isActive ? (
                                                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                                                    Hoạt động
                                                </span>
                                            ) : (
                                                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800">
                                                    Đã khóa
                                                </span>
                                            )}
                                        </div>
                                    </td>

                                    {/* Cột Dịch vụ */}
                                    <td className="px-6 py-4">
                                        <div className="flex flex-col gap-1 max-w-[250px]">
                                            {activeTab === 'pending' && provider.requestedServices && provider.requestedServices.length > 0 ? (
                                                // Hiển thị chi tiết dịch vụ kèm giá cho tab Chờ duyệt
                                                provider.requestedServices.map((service, idx) => {
                                                    const sId = service.serviceId || service.id;
                                                    const sName = serviceMap[sId] || service.name || 'Dịch vụ';
                                                    const sPrice = service.price ? parseInt(service.price).toLocaleString('vi-VN') : '0';
                                                    return (
                                                        <div key={idx} className="flex justify-between items-center text-xs border-b border-dashed border-slate-200 dark:border-slate-700 last:border-0 py-1">
                                                            <span className="font-medium text-slate-700 dark:text-slate-300 mr-2">{sName}</span>
                                                            <span className="text-green-600 font-bold whitespace-nowrap">{sPrice} đ</span>
                                                        </div>
                                                    );
                                                })
                                            ) : (
                                                // Hiển thị Categories cho các tab khác
                                                <div className="flex flex-wrap gap-1">
                                                    {provider.serviceIds && provider.serviceIds.length > 0 ? (
                                                        <>
                                                            {[...new Set(provider.serviceIds.map(sid => serviceCategoryMap[sid]))]
                                                                .filter(Boolean)
                                                                .slice(0, 2)
                                                                .map((cat, idx) => (
                                                                    <span key={idx} className="px-2 py-0.5 text-xs rounded bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-300 border border-blue-100 dark:border-blue-800">
                                                                        {cat}
                                                                    </span>
                                                                ))}
                                                            {[...new Set(provider.serviceIds.map(sid => serviceCategoryMap[sid]))].filter(Boolean).length > 2 && (
                                                                <span className="px-2 py-0.5 text-xs rounded bg-slate-100 dark:bg-slate-700 text-slate-500 border border-slate-200 dark:border-slate-600">
                                                                    +{[...new Set(provider.serviceIds.map(sid => serviceCategoryMap[sid]))].filter(Boolean).length - 2}
                                                                </span>
                                                            )}
                                                        </>
                                                    ) : (
                                                        <span className="text-xs text-slate-400 italic">--</span>
                                                    )}
                                                </div>
                                            )}
                                        </div>
                                    </td>

                                    {/* Cột Thao tác */}
                                    <td className="px-6 py-4 text-right">
                                        <div className="flex items-center justify-end gap-2">
                                            <button
                                                onClick={() => onView(provider)}
                                                className="p-1.5 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-md text-slate-500 hover:text-green-600 transition-colors"
                                                title="Xem chi tiết"
                                            >
                                                <span className="material-symbols-outlined text-[20px]">visibility</span>
                                            </button>

                                            {(activeTab === 'pending' || activeTab === 'rejected') && (
                                                <button
                                                    onClick={() => onApprove(provider.userId || provider.id, provider.id)}
                                                    className="p-1.5 hover:bg-blue-100 dark:hover:bg-blue-900/40 rounded-md text-slate-500 hover:text-blue-600 transition-colors"
                                                    title="Duyệt"
                                                >
                                                    <span className="material-symbols-outlined text-[20px]">check_circle</span>
                                                </button>
                                            )}

                                            {activeTab === 'pending' && (
                                                <button
                                                    onClick={() => onReject(provider.userId || provider.id, provider.id)}
                                                    className="p-1.5 hover:bg-red-100 dark:hover:bg-red-900/40 rounded-md text-slate-500 hover:text-red-600 transition-colors"
                                                    title="Từ chối"
                                                >
                                                    <span className="material-symbols-outlined text-[20px]">cancel</span>
                                                </button>
                                            )}

                                            {activeTab === 'approved' && (
                                                <button
                                                    onClick={() => onToggleStatus(provider.id, provider.isActive)}
                                                    className={`p-1.5 rounded-md text-slate-500 transition-colors ${provider.isActive ? 'hover:bg-amber-100 hover:text-amber-600' : 'hover:bg-green-100 hover:text-green-600'}`}
                                                    title={provider.isActive ? "Khóa tài khoản" : "Mở khóa"}
                                                >
                                                    <span className="material-symbols-outlined text-[20px]">
                                                        {provider.isActive ? 'lock_open' : 'lock'}
                                                    </span>
                                                </button>
                                            )}

                                            <button
                                                onClick={() => onEdit(provider)}
                                                className="p-1.5 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-md text-slate-500 transition-colors"
                                                title="Sửa"
                                            >
                                                <span className="material-symbols-outlined text-[20px]">edit</span>
                                            </button>

                                            <button
                                                className="p-1.5 hover:bg-red-100 dark:hover:bg-red-900/40 rounded-md text-slate-500 hover:text-red-600 transition-colors"
                                                title="Xóa"
                                                onClick={() => onDelete(provider.userId || provider.id)}
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

export default ProviderTable;
