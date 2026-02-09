import React, { useState, useEffect } from 'react';
import { getAllCustomers, getCustomerOrderCount, deleteCustomer, createCustomer, updateCustomer } from '../../services/customerService';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { firestore } from '../../firebase/config';
import CustomerModal from './CustomerModal';

const CustomerManager = () => {
    const [customers, setCustomers] = useState([]);
    const [allCustomers, setAllCustomers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [currentPage, setCurrentPage] = useState(1);

    const [selectedStatus, setSelectedStatus] = useState('all');
    const [error, setError] = useState(null);

    // Modal state
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingCustomer, setEditingCustomer] = useState(null);
    const [isEditing, setIsEditing] = useState(false);

    // Lấy dữ liệu khách hàng từ Firebase
    useEffect(() => {
        fetchCustomers();
    }, []);

    const fetchCustomers = async () => {
        try {
            setLoading(true);
            setError(null);

            // Lấy tất cả khách hàng
            const customersData = await getAllCustomers();

            // Lấy số đơn hàng cho mỗi khách hàng
            const customersWithOrders = await Promise.all(
                customersData.map(async (customer) => {
                    try {
                        const bookingsRef = collection(firestore, 'bookings');
                        const q = query(bookingsRef, where('customerId', '==', customer.id));
                        const querySnapshot = await getDocs(q);

                        return {
                            ...customer,
                            ordersCount: querySnapshot.size,
                            // Xác định status dựa trên isActive field
                            status: customer.isActive === false ? 'inactive' :
                                customer.isVerified === false ? 'pending' : 'active'
                        };
                    } catch (err) {
                        console.error(`Error fetching orders for customer ${customer.id}:`, err);
                        return {
                            ...customer,
                            ordersCount: 0,
                            status: customer.isActive === false ? 'inactive' :
                                customer.isVerified === false ? 'pending' : 'active'
                        };
                    }
                })
            );

            setAllCustomers(customersWithOrders);
            setCustomers(customersWithOrders);
        } catch (err) {
            console.error('Error fetching customers:', err);
            setError('Không thể tải danh sách khách hàng. Vui lòng thử lại.');
        } finally {
            setLoading(false);
        }
    };

    // Xử lý xóa khách hàng
    const handleDeleteCustomer = async (customerId) => {
        if (window.confirm('Bạn có chắc chắn muốn xóa khách hàng này?')) {
            try {
                await deleteCustomer(customerId);
                // Refresh danh sách
                fetchCustomers();
                alert('Đã xóa khách hàng thành công!');
            } catch (err) {
                console.error('Error deleting customer:', err);
                alert('Không thể xóa khách hàng. Vui lòng thử lại.');
            }
        }
    };

    const handleAddClick = () => {
        setEditingCustomer(null);
        setIsEditing(false);
        setIsModalOpen(true);
    };

    const handleEditClick = (customer) => {
        setEditingCustomer(customer);
        setIsEditing(true);
        setIsModalOpen(true);
    };

    const handleCreateCustomer = async (data) => {
        try {
            await createCustomer(data);
            setIsModalOpen(false);
            fetchCustomers();
            alert('Thêm khách hàng thành công!');
        } catch (error) {
            console.error('Error creating customer:', error);
            alert('Lỗi khi thêm khách hàng.');
        }
    };

    const handleUpdateCustomer = async (data) => {
        try {
            await updateCustomer(editingCustomer.id, data);
            setIsModalOpen(false);
            fetchCustomers();
            alert('Cập nhật khách hàng thành công!');
        } catch (error) {
            console.error('Error updating customer:', error);
            alert('Lỗi khi cập nhật khách hàng.');
        }
    };

    const handleCopyId = (id) => {
        navigator.clipboard.writeText(id);
        // Có thể thêm toast notification ở đây
    };

    const filteredCustomers = customers.filter(customer => {
        const searchLower = searchTerm.toLowerCase();
        const matchesSearch = (
            (customer.full_name && customer.full_name.toLowerCase().includes(searchLower)) ||
            (customer.name && customer.name.toLowerCase().includes(searchLower)) ||
            (customer.email && customer.email.toLowerCase().includes(searchLower)) ||
            (customer.phoneNumber && customer.phoneNumber.includes(searchTerm))
        );
        const matchesStatus = selectedStatus === 'all' || customer.status === selectedStatus;
        return matchesSearch && matchesStatus;
    });

    const getInitials = (name) => {
        if (!name) return 'NA';
        const names = name.split(' ');
        if (names.length >= 2) {
            return (names[0].charAt(0) + names[names.length - 1].charAt(0)).toUpperCase();
        }
        return name.charAt(0).toUpperCase();
    };

    const getStatusBadge = (status) => {
        switch (status) {
            case 'active':
                return (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400">
                        <span className="size-1.5 rounded-full bg-green-500"></span>
                        Đang hoạt động
                    </span>
                );
            case 'inactive':
                return (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400">
                        <span className="size-1.5 rounded-full bg-slate-400"></span>
                        Ngừng hoạt động
                    </span>
                );
            case 'pending':
                return (
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-400">
                        <span className="size-1.5 rounded-full bg-amber-500"></span>
                        Đang chờ
                    </span>
                );
            default:
                return null;
        }
    };

    const totalCustomers = allCustomers.length;
    const itemsPerPage = 10;
    const totalPages = Math.ceil(totalCustomers / itemsPerPage);

    // Phân trang
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const paginatedCustomers = filteredCustomers.slice(startIndex, endIndex);

    return (
        <div className="flex-1 flex flex-col bg-background-light dark:bg-background-dark min-w-0">
            <div className="p-8 space-y-6 max-w-[1400px] mx-auto w-full">
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-white">Quản lý Khách hàng</h2>
                        <p className="text-slate-500 dark:text-slate-400 mt-1">Xem và quản lý tất cả thông tin khách hàng đăng ký trên hệ thống.</p>
                    </div>
                    <button
                        onClick={handleAddClick}
                        className="bg-[#4CAE4F] hover:bg-[#439d46] text-white font-bold py-2.5 px-6 rounded-lg transition-all flex items-center justify-center gap-2 shadow-lg shadow-green-500/20"
                    >
                        <span className="material-symbols-outlined">person_add</span>
                        Thêm khách hàng mới
                    </button>
                </div>

                {error && (
                    <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 flex items-center gap-3">
                        <span className="material-symbols-outlined text-red-600">error</span>
                        <p className="text-red-600 dark:text-red-400 text-sm">{error}</p>
                        <button
                            onClick={fetchCustomers}
                            className="ml-auto px-3 py-1 bg-red-600 hover:bg-red-700 text-white text-sm rounded-lg"
                        >
                            Thử lại
                        </button>
                    </div>
                )}

                <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 flex flex-wrap gap-4 items-center shadow-sm">
                    <div className="relative flex-1 min-w-[300px]">
                        <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">search</span>
                        <input
                            className="w-full pl-10 pr-4 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm placeholder:text-slate-500 transition-all"
                            placeholder="Tìm kiếm theo tên, email, hoặc số điện thoại..."
                            type="text"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                    <div className="flex gap-3 items-center">

                        <div className="relative">
                            <select
                                className="appearance-none pl-4 pr-10 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 text-sm font-medium min-w-[150px]"
                                value={selectedStatus}
                                onChange={(e) => setSelectedStatus(e.target.value)}
                            >
                                <option value="all">Trạng thái: Tất cả</option>
                                <option value="active">Đang hoạt động</option>
                                <option value="inactive">Ngừng hoạt động</option>
                                <option value="pending">Đang chờ</option>
                            </select>
                            <span className="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">expand_more</span>
                        </div>

                    </div>
                </div>

                <div className="bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-xl overflow-hidden shadow-sm">
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                                    <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Tên khách hàng</th>
                                    <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Số điện thoại</th>
                                    <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500">Email</th>
                                    <th className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 text-center">Tổng đơn hàng</th>
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
                                ) : paginatedCustomers.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="px-6 py-10 text-center text-slate-500">
                                            {searchTerm || selectedStatus !== 'all'
                                                ? 'Không tìm thấy khách hàng nào phù hợp.'
                                                : 'Chưa có khách hàng nào trong hệ thống.'}
                                        </td>
                                    </tr>
                                ) : (
                                    paginatedCustomers.map((customer) => (
                                        <tr key={customer.id} className="hover:bg-slate-50/80 dark:hover:bg-slate-800/30 transition-colors group">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    {customer.avatar_url || customer.avatarUrl || customer.photoURL ? (
                                                        <img
                                                            className="size-10 rounded-full object-cover"
                                                            src={customer.avatar_url || customer.avatarUrl || customer.photoURL}
                                                            alt=""
                                                            onError={(e) => {
                                                                e.target.style.display = 'none';
                                                                e.target.nextSibling.style.display = 'flex';
                                                            }}
                                                        />
                                                    ) : null}
                                                    <div
                                                        className="size-10 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center font-bold text-green-700 dark:text-green-400"
                                                        style={{ display: customer.avatar_url || customer.avatarUrl || customer.photoURL ? 'none' : 'flex' }}
                                                    >
                                                        {getInitials(customer.full_name || customer.name || customer.displayName)}
                                                    </div>
                                                    <div>
                                                        <p className="text-sm font-semibold">{customer.full_name || customer.name || customer.displayName || 'Chưa cập nhật'}</p>
                                                        <div className="flex items-center gap-1 group/id">
                                                            <p className="text-xs text-slate-500 font-mono" title={customer.id}>
                                                                ID: {customer.id.slice(0, 8)}...
                                                            </p>
                                                            <button
                                                                onClick={() => handleCopyId(customer.id)}
                                                                className="text-slate-400 hover:text-green-600 opacity-0 group-hover/id:opacity-100 transition-all"
                                                                title="Sao chép ID"
                                                            >
                                                                <span className="material-symbols-outlined text-[14px]">content_copy</span>
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4">
                                                <p className="text-sm">{customer.phoneNumber || customer.phone || '---'}</p>
                                            </td>
                                            <td className="px-6 py-4">
                                                <p className="text-sm">{customer.email || '---'}</p>
                                            </td>
                                            <td className="px-6 py-4 text-center">
                                                <span className="px-3 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-sm font-medium">
                                                    {customer.ordersCount || 0}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                {getStatusBadge(customer.status)}
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                    <button className="p-1.5 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-md text-slate-500" title="Xem chi tiết">
                                                        <span className="material-symbols-outlined text-[20px]">visibility</span>
                                                    </button>
                                                    <button
                                                        onClick={() => handleEditClick(customer)}
                                                        className="p-1.5 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-md text-slate-500"
                                                        title="Sửa"
                                                    >
                                                        <span className="material-symbols-outlined text-[20px]">edit</span>
                                                    </button>
                                                    <button
                                                        className="p-1.5 hover:bg-red-100 dark:hover:bg-red-900/40 rounded-md text-slate-500 hover:text-red-600"
                                                        title="Xóa"
                                                        onClick={() => handleDeleteCustomer(customer.id)}
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
                    <div className="px-6 py-4 flex items-center justify-between bg-slate-50/50 dark:bg-slate-800/30 border-t border-slate-200 dark:border-slate-800">
                        <p className="text-xs text-slate-500 font-medium">
                            Hiển thị <span className="text-slate-900 dark:text-slate-100">{startIndex + 1}</span> đến <span className="text-slate-900 dark:text-slate-100">{Math.min(endIndex, filteredCustomers.length)}</span> trong số <span className="text-slate-900 dark:text-slate-100">{filteredCustomers.length}</span> khách hàng
                        </p>
                        <div className="flex items-center gap-2">
                            <button
                                className="p-1.5 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-white dark:hover:bg-slate-800 text-slate-400 disabled:opacity-50 disabled:cursor-not-allowed"
                                disabled={currentPage === 1}
                                onClick={() => setCurrentPage(prev => Math.max(1, prev - 1))}
                            >
                                <span className="material-symbols-outlined">chevron_left</span>
                            </button>
                            <div className="flex items-center gap-1">
                                {[...Array(Math.min(totalPages, 5))].map((_, index) => {
                                    let pageNum;
                                    if (totalPages <= 5) {
                                        pageNum = index + 1;
                                    } else if (currentPage <= 3) {
                                        pageNum = index + 1;
                                    } else if (currentPage >= totalPages - 2) {
                                        pageNum = totalPages - 4 + index;
                                    } else {
                                        pageNum = currentPage - 2 + index;
                                    }

                                    return (
                                        <button
                                            key={pageNum}
                                            className={`size-8 rounded-lg text-xs font-medium ${currentPage === pageNum ? 'bg-[var(--primary-color)] text-white' : 'hover:bg-slate-200 dark:hover:bg-slate-800'}`}
                                            onClick={() => setCurrentPage(pageNum)}
                                        >
                                            {pageNum}
                                        </button>
                                    );
                                })}
                                {totalPages > 5 && currentPage < totalPages - 2 && (
                                    <>
                                        <span className="text-slate-400 mx-1">...</span>
                                        <button
                                            className="size-8 rounded-lg text-xs font-medium hover:bg-slate-200 dark:hover:bg-slate-800"
                                            onClick={() => setCurrentPage(totalPages)}
                                        >
                                            {totalPages}
                                        </button>
                                    </>
                                )}
                            </div>
                            <button
                                className="p-1.5 rounded-lg border border-slate-200 dark:border-slate-700 hover:bg-white dark:hover:bg-slate-800 text-slate-600 dark:text-slate-400 disabled:opacity-50 disabled:cursor-not-allowed"
                                disabled={currentPage === totalPages || totalPages === 0}
                                onClick={() => setCurrentPage(prev => Math.min(totalPages, prev + 1))}
                            >
                                <span className="material-symbols-outlined">chevron_right</span>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            {/* Modal */}
            <CustomerModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={isEditing ? handleUpdateCustomer : handleCreateCustomer}
                customer={editingCustomer}
                isEditing={isEditing}
            />
        </div>
    );
};

export default CustomerManager;
