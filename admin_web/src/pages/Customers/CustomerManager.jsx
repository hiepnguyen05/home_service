import React, { useEffect, useState, useCallback } from 'react';
import { 
    getAllCustomers, 
    searchCustomers, 
    deleteCustomer, 
    updateCustomer, 
    createCustomer,
    getCustomerOrderCount 
} from '../../services/customerService';
import CustomerTable from './components/CustomerTable';
import CustomerFilter from './components/CustomerFilter';
import CustomerModal from './CustomerModal';

/**
 * Component quản lý khách hàng (Customer Manager).
 * Được thiết kế theo phong cách trang Quản lý Thợ để đảm bảo đồng nhất UI/UX.
 */
const CustomerManager = () => {
    // --- States ---
    const [customers, setCustomers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [error, setError] = useState(null);
    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 10;

    // Modal states
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingCustomer, setEditingCustomer] = useState(null);
    const [isEditing, setIsEditing] = useState(false);
    const [viewMode, setViewMode] = useState(false);

    // --- Fetch Data ---
    const fetchCustomers = useCallback(async () => {
        try {
            setLoading(true);
            const data = await getAllCustomers();
            
            // Fetch order counts for each customer in parallel
            const customersWithOrders = await Promise.all(data.map(async (customer) => {
                const orderCount = await getCustomerOrderCount(customer.id);
                return { ...customer, orderCount };
            }));
            
            setCustomers(customersWithOrders);
            setError(null);
        } catch (err) {
            console.error('Error fetching customers:', err);
            setError('Không thể tải danh sách khách hàng. Vui lòng thử lại sau.');
        } finally {
            setLoading(false);
        }
    }, []);

    useEffect(() => {
        fetchCustomers();
    }, [fetchCustomers]);

    // --- Handlers ---
    const handleSearch = async (term) => {
        setSearchTerm(term);
        setCurrentPage(1);
        if (term.length > 2) {
            try {
                const results = await searchCustomers(term);
                // Also need to fetch order counts for search results
                const resultsWithOrders = await Promise.all(results.map(async (customer) => {
                    const orderCount = await getCustomerOrderCount(customer.id);
                    return { ...customer, orderCount };
                }));
                setCustomers(resultsWithOrders);
            } catch (err) {
                console.error('Error searching customers:', err);
            }
        } else if (term.length === 0) {
            fetchCustomers();
        }
    };

    const handleAddClick = () => {
        setEditingCustomer(null);
        setIsEditing(false);
        setViewMode(false);
        setIsModalOpen(true);
    };

    const handleEditClick = (customer) => {
        setEditingCustomer(customer);
        setIsEditing(true);
        setViewMode(false);
        setIsModalOpen(true);
    };

    const handleViewClick = (customer) => {
        setEditingCustomer(customer);
        setIsEditing(false);
        setViewMode(true);
        setIsModalOpen(true);
    };

    const handleDelete = async (id) => {
        if (window.confirm('Bạn có chắc chắn muốn xóa khách hàng này?')) {
            try {
                await deleteCustomer(id);
                fetchCustomers();
                alert('Đã xóa khách hàng thành công!');
            } catch (err) {
                alert('Lỗi khi xóa khách hàng.');
            }
        }
    };

    const handleToggleStatus = async (id, currentStatus) => {
        const action = currentStatus ? 'khóa' : 'mở khóa';
        if (window.confirm(`Bạn có chắc muốn ${action} khách hàng này?`)) {
            try {
                await updateCustomer(id, { isActive: !currentStatus });
                fetchCustomers();
            } catch (err) {
                alert(`Lỗi khi ${action} khách hàng.`);
            }
        }
    };

    const handleModalSubmit = async (formData) => {
        try {
            if (isEditing) {
                await updateCustomer(editingCustomer.id, formData);
                alert('Cập nhật khách hàng thành công!');
            } else {
                await createCustomer(formData);
                alert('Thêm khách hàng thành công!');
            }
            setIsModalOpen(false);
            fetchCustomers();
        } catch (err) {
            console.error('Error submitting customer:', err);
            alert('Lỗi khi lưu thông tin khách hàng.');
        }
    };

    const handleCopyId = (id) => {
        navigator.clipboard.writeText(id);
        // Could add a toast notification here
    };

    const getInitials = (name) => {
        if (!name) return 'U';
        const names = name.split(' ');
        if (names.length >= 2) {
            return (names[0].charAt(0) + names[names.length - 1].charAt(0)).toUpperCase();
        }
        return name.charAt(0).toUpperCase();
    };

    // --- Pagination ---
    const totalPages = Math.max(1, Math.ceil(customers.length / itemsPerPage));
    const paginatedCustomers = customers.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

    return (
        <div className="flex-1 flex flex-col bg-[#F8FAFC] dark:bg-[#0F172A] min-w-0">
            <div className="p-8 space-y-6 max-w-[1400px] mx-auto w-full">
                {/* Header Section */}
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-white">Quản lý Khách hàng</h2>
                        <p className="text-slate-500 dark:text-slate-400 mt-1 font-medium">
                            Tổng cộng <span className="text-green-600 font-bold">{customers.length}</span> tài khoản trên hệ thống.
                        </p>
                    </div>
                    <button
                        onClick={handleAddClick}
                        className="bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 px-6 rounded-xl transition-all flex items-center justify-center gap-2 shadow-lg shadow-green-500/20 active:scale-95"
                    >
                        <span className="material-symbols-outlined">person_add</span>
                        Thêm khách hàng mới
                    </button>
                </div>

                {/* Error Banner */}
                {error && (
                    <div className="bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-800 rounded-xl p-4 flex items-center gap-3 animate-in fade-in slide-in-from-top-4">
                        <span className="material-symbols-outlined text-red-600">error</span>
                        <p className="text-red-600 dark:text-red-400 text-sm font-semibold">{error}</p>
                        <button onClick={fetchCustomers} className="ml-auto text-xs font-black uppercase text-red-700 hover:underline">Thử lại</button>
                    </div>
                )}

                {/* Filter Component */}
                <CustomerFilter 
                    searchTerm={searchTerm} 
                    setSearchTerm={handleSearch} 
                />

                {/* Table Component */}
                <CustomerTable
                    customers={paginatedCustomers}
                    loading={loading}
                    onView={handleViewClick}
                    onEdit={handleEditClick}
                    onDelete={handleDelete}
                    onToggleStatus={handleToggleStatus}
                    onCopyId={handleCopyId}
                    getInitials={getInitials}
                />

                {/* Pagination */}
                {totalPages > 1 && (
                    <div className="flex items-center justify-between pt-4 pb-10">
                        <p className="text-[11px] font-black uppercase tracking-widest text-slate-400 italic">
                            Trang {currentPage} trên {totalPages}
                        </p>
                        <div className="flex gap-2">
                            <button
                                disabled={currentPage === 1}
                                onClick={() => { setCurrentPage(c => c - 1); window.scrollTo({ top: 0, behavior: 'smooth' }); }}
                                className="size-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 flex items-center justify-center hover:bg-slate-50 disabled:opacity-30 transition-all shadow-sm"
                            >
                                <span className="material-symbols-outlined">chevron_left</span>
                            </button>
                            <button
                                onClick={() => { setCurrentPage(c => c + 1); window.scrollTo({ top: 0, behavior: 'smooth' }); }}
                                disabled={currentPage === totalPages}
                                className="size-10 rounded-xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 flex items-center justify-center hover:bg-slate-50 disabled:opacity-30 transition-all shadow-sm"
                            >
                                <span className="material-symbols-outlined">chevron_right</span>
                            </button>
                        </div>
                    </div>
                )}

                {/* Modal Component */}
                <CustomerModal
                    isOpen={isModalOpen}
                    onClose={() => setIsModalOpen(false)}
                    onSubmit={handleModalSubmit}
                    customer={editingCustomer}
                    isEditing={isEditing}
                    viewMode={viewMode}
                />
            </div>
        </div>
    );
};

export default CustomerManager;
