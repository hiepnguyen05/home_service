import React, { useState } from 'react';
import {
    deleteProvider,
    createProvider,
    updateProvider,
    approveProvider,
    rejectProvider,
    toggleProviderStatus
} from '../../services/providerService';
import ProviderModal from './ProviderModal';
import useProviderData from '../../hooks/useProviderData';

// Import các component con (SOLID: Single Responsibility Principle)
import ProviderTabs from './components/ProviderTabs';
import ProviderFilter from './components/ProviderFilter';
import ProviderTable from './components/ProviderTable';

/**
 * Component quản lý nhà cung cấp (Provider Manager).
 * Chịu trách nhiệm chính về logic business, gọi API và quản lý state.
 * Phần giao diện chi tiết được tách ra các component con.
 * 
 * @component
 */
const ProviderManager = () => {
    // Sử dụng custom hook để lấy dữ liệu (Separation of Concerns)
    const {
        providers,
        pendingRequests, // Get pending requests separately
        rejectedRequests, // Get rejected requests separately
        categories,
        services,
        serviceMap,
        serviceCategoryMap,
        loading,
        error: hookError,
        refreshData
    } = useProviderData();

    // State quản lý tìm kiếm và phân trang
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('');
    const [selectedService, setSelectedService] = useState('');
    const [currentPage, setCurrentPage] = useState(1);

    // State quản lý Tabs
    const [activeTab, setActiveTab] = useState('pending');

    // State quản lý chế độ xem chi tiết (View Mode)
    const [viewMode, setViewMode] = useState(false);

    // State quản lý Modal (Thêm/Sửa/Xem)
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingProvider, setEditingProvider] = useState(null);
    const [isEditing, setIsEditing] = useState(false);



    // ... 

    // Helper to check if provider matches category
    const providerMatchesCategory = (provider, categoryId) => {
        if (!categoryId) return true;

        // Find all services in this category
        const servicesInCat = services.filter(s => (s.category || s.categoryId) === categoryId).map(s => s.id);

        // Check if provider offers any of these services
        // Providers have serviceIds array
        if (!provider.serviceIds || !Array.isArray(provider.serviceIds)) return false;

        return provider.serviceIds.some(sId => servicesInCat.includes(sId));
    };





    // --- Các hàm xử lý sự kiện (Event Handlers) ---

    /**
     * Mở modal để thêm thợ mới.
     */
    const handleAddClick = () => {
        setEditingProvider(null);
        setIsEditing(false);
        setViewMode(false);
        setIsModalOpen(true);
    };

    /**
     * Mở modal để chỉnh sửa thông tin thợ.
     * @param {Object} provider - Thông tin thợ cần sửa.
     */
    const handleEditClick = (provider) => {
        setEditingProvider(provider);
        setIsEditing(true);
        setViewMode(false);
        setIsModalOpen(true);
    };

    /**
     * Mở modal để xem chi tiết thông tin thợ (Read-only).
     * @param {Object} provider - Thông tin thợ cần xem.
     */
    const handleViewClick = (provider) => {
        setEditingProvider(provider);
        setIsEditing(false);
        setViewMode(true);
        setIsModalOpen(true);
    };

    /**
     * Xử lý thêm mới thợ.
     * @param {Object} data - Dữ liệu form.
     */
    const handleCreateProvider = async (data) => {
        try {
            await createProvider(data);
            setIsModalOpen(false);
            refreshData();
            alert('Thêm thợ thành công!');
        } catch (error) {
            console.error('Error creating provider:', error);
            alert('Lỗi khi thêm thợ.');
        }
    };

    /**
     * Xử lý cập nhật thông tin thợ.
     * @param {Object} data - Dữ liệu form.
     */
    const handleUpdateProvider = async (data) => {
        try {
            await updateProvider(editingProvider.id, data);
            setIsModalOpen(false);
            refreshData();
            alert('Cập nhật thợ thành công!');
        } catch (error) {
            console.error('Error updating provider:', error);
            alert('Lỗi khi cập nhật thợ.');
        }
    };

    /**
     * Xử lý xóa thợ.
     * @param {string} providerId - ID của thợ cần xóa.
     */
    const handleDeleteProvider = async (providerId) => {
        if (window.confirm('Bạn có chắc chắn muốn xóa thợ này?')) {
            try {
                await deleteProvider(providerId);
                refreshData();
                alert('Đã xóa thợ thành công!');
            } catch (err) {
                console.error('Error deleting provider:', err);
                alert('Không thể xóa thợ. Vui lòng thử lại.');
            }
        }
    };

    /**
     * Xử lý duyệt thợ (Approve).
     * @param {string} providerId - ID của thợ cần duyệt.
     */
    const handleApprove = async (providerId) => {
        if (window.confirm('Xác nhận duyệt thợ này?')) {
            try {
                await approveProvider(providerId);
                refreshData();
                alert('Đã duyệt thợ thành công!');
            } catch (err) {
                console.error('Error approving provider:', err);
                alert('Lỗi khi duyệt thợ.');
            }
        }
    };

    /**
     * Xử lý từ chối thợ (Reject).
     * @param {string} providerId - ID của thợ bị từ chối.
     */
    const handleReject = async (providerId) => {
        const reason = window.prompt('Nhập lý do từ chối (bắt buộc):');
        if (reason === null) return; // Người dùng ấn Cancel
        if (!reason.trim()) {
            alert('Vui lòng nhập lý do từ chối!');
            return;
        }

        if (window.confirm('Xác nhận từ chối thợ này?')) {
            try {
                await rejectProvider(providerId, reason);
                refreshData();
                alert('Đã từ chối thợ!');
            } catch (err) {
                console.error('Error rejecting provider:', err);
                alert('Lỗi khi từ chối thợ.');
            }
        }
    };

    /**
     * Xử lý khóa/mở khóa tài khoản thợ.
     * @param {string} providerId - ID thợ.
     * @param {boolean} currentStatus - Trạng thái hiện tại (true: active, false: locked).
     */
    const handleToggleStatus = async (providerId, currentStatus) => {
        const action = currentStatus ? 'khóa' : 'mở khóa';
        if (window.confirm(`Bạn có chắc muốn ${action} thợ này?`)) {
            try {
                await toggleProviderStatus(providerId, currentStatus);
                refreshData();
            } catch (err) {
                console.error('Error toggling provider status:', err);
                alert(`Lỗi khi ${action} thợ.`);
            }
        }
    };

    /**
     * Copy ID vào clipboard.
     * @param {string} id - ID cần copy.
     */
    const handleCopyId = (id) => {
        navigator.clipboard.writeText(id);
    };

    /**
     * Lấy tên viết tắt (Initials) từ tên đầy đủ.
     * @param {string} name - Tên đầy đủ.
     * @returns {string} - Tên viết tắt (VD: "Nguyen Van A" -> "NA").
     */
    const getInitials = (name) => {
        if (!name) return 'NA';
        const names = name.split(' ');
        if (names.length >= 2) {
            return (names[0].charAt(0) + names[names.length - 1].charAt(0)).toUpperCase();
        }
        return name.charAt(0).toUpperCase();
    };

    // --- Logic lọc và phân trang (Filter & Pagination) ---

    // --- Logic lọc và phân trang (Filter & Pagination) ---

    // --- Logic lọc và phân trang (Filter & Pagination) ---

    // Xác định nguồn dữ liệu dựa trên Tab
    let dataSource = [];
    if (activeTab === 'pending') {
        dataSource = pendingRequests;
    } else if (activeTab === 'rejected') {
        // Ưu tiên lấy từ rejectedRequests (từ partner_requests) để hiển thị cả những đơn không có User
        // Tuy nhiên, có thể merge với providers đã bị reject nếu cần thiết.
        // Hiện tại dùng rejectedRequests là đủ bao quát (vì mọi reject đều update vào partner_requests)
        dataSource = rejectedRequests;
    } else {
        dataSource = providers;
    }

    const filteredProviders = dataSource.filter(provider => {
        const searchLower = searchTerm.toLowerCase();
        const matchesSearch = (
            (provider.full_name && provider.full_name.toLowerCase().includes(searchLower)) ||
            (provider.name && provider.name.toLowerCase().includes(searchLower)) ||
            (provider.email && provider.email.toLowerCase().includes(searchLower)) ||
            (provider.phoneNumber && provider.phoneNumber.includes(searchTerm))
        );

        const matchesCategory = selectedCategory ? providerMatchesCategory(provider, selectedCategory) : true;
        const matchesService = selectedService ? (provider.serviceIds && provider.serviceIds.includes(selectedService)) : true;

        // Debug filtering
        if (selectedCategory || selectedService) {
            console.log('Filtering:', {
                providerName: provider.full_name || provider.name,
                serviceIds: provider.serviceIds,
                selectedCategory,
                selectedService,
                matchesCategory,
                matchesService
            });
        }

        let matchesTab = false;
        if (activeTab === 'pending') {
            matchesTab = true;
        } else if (activeTab === 'approved') {
            matchesTab = provider.verificationStatus === 'verified' || provider.isVerified === true;
        } else if (activeTab === 'rejected') {
            // Với rejectedRequests, mặc định hiển thị hết
            matchesTab = true;
        }

        return matchesSearch && matchesTab && matchesCategory && matchesService;
    });

    const itemsPerPage = 10;
    // const totalPages = Math.ceil(filteredProviders.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedProviders = filteredProviders.slice(startIndex, startIndex + itemsPerPage);

    // --- Render View ---

    return (
        <div className="flex-1 flex flex-col bg-background-light dark:bg-background-dark min-w-0">
            <div className="p-8 space-y-6 max-w-[1400px] mx-auto w-full">

                {/* Header Section */}
                <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                    <div>
                        <h2 className="text-3xl font-bold tracking-tight text-slate-900 dark:text-white">Quản lý Thợ</h2>
                        <p className="text-slate-500 dark:text-slate-400 mt-1">Xem và quản lý danh sách thợ/nhà cung cấp dịch vụ.</p>
                    </div>
                    <button
                        onClick={handleAddClick}
                        className="bg-[#4CAE4F] hover:bg-[#439d46] text-white font-bold py-2.5 px-6 rounded-lg transition-all flex items-center justify-center gap-2 shadow-lg shadow-green-500/20"
                    >
                        <span className="material-symbols-outlined">person_add</span>
                        Thêm thợ mới
                    </button>
                </div>

                {/* Tabs Component */}
                <ProviderTabs
                    activeTab={activeTab}
                    setActiveTab={setActiveTab}
                    setCurrentPage={setCurrentPage}
                    pendingCount={pendingRequests.length}
                />

                {/* Error Banner */}
                {hookError && (
                    <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 flex items-center gap-3">
                        <span className="material-symbols-outlined text-red-600">error</span>
                        <p className="text-red-600 dark:text-red-400 text-sm">{hookError}</p>
                        <button
                            onClick={refreshData}
                            className="ml-auto px-3 py-1 bg-red-600 hover:bg-red-700 text-white text-sm rounded-lg"
                        >
                            Thử lại
                        </button>
                    </div>
                )}

                {/* Filter Component */}
                <ProviderFilter
                    searchTerm={searchTerm}
                    setSearchTerm={setSearchTerm}
                    categories={categories}
                    services={services}
                    selectedCategory={selectedCategory}
                    setSelectedCategory={setSelectedCategory}
                    selectedService={selectedService}
                    setSelectedService={setSelectedService}
                />

                {/* Table Component */}
                <ProviderTable
                    providers={paginatedProviders}
                    loading={loading}
                    serviceCategoryMap={serviceCategoryMap}
                    serviceMap={serviceMap}
                    activeTab={activeTab}
                    onView={handleViewClick}
                    onApprove={handleApprove}
                    onReject={handleReject}
                    onToggleStatus={handleToggleStatus}
                    onEdit={handleEditClick}
                    onDelete={handleDeleteProvider}
                    onCopyId={handleCopyId}
                    getInitials={getInitials}
                />

                {/* Modal Component */}
                <ProviderModal
                    isOpen={isModalOpen}
                    onClose={() => setIsModalOpen(false)}
                    onSubmit={isEditing ? handleUpdateProvider : handleCreateProvider}
                    provider={editingProvider}
                    isEditing={isEditing}
                    viewMode={viewMode}
                    serviceMap={serviceMap}
                />
            </div>
        </div>
    );
};

export default ProviderManager;
