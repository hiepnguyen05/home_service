import React, { useState, useMemo } from 'react';
import { useServices } from '../../hooks/useServices';
import { useCategories } from '../../hooks/useCategories';
import ServiceTable from './components/ServiceTable';
import ServiceModal from './components/ServiceModal';
import ServiceDetailModal from './components/ServiceDetailModal';
import ServiceFilters from './components/ServiceFilters';
import { FaPlus, FaBroom } from 'react-icons/fa';

const ServiceManager = () => {
    // Hooks
    const {
        services,
        loading: servicesLoading,
        addService,
        updateService,
        deleteService,
        toggleServiceStatus
    } = useServices();

    const {
        categories,
        loading: categoriesLoading
    } = useCategories();

    // Local State
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingService, setEditingService] = useState(null);
    const [viewingService, setViewingService] = useState(null);
    const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedCategory, setSelectedCategory] = useState('');

    // Pagination State
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage] = useState(10); // Display 10 items per page

    // Filter Logic
    const filteredServices = useMemo(() => {
        return services.filter(service => {
            const matchesSearch = service.name.toLowerCase().includes(searchTerm.toLowerCase());
            const matchesCategory = selectedCategory ? service.categoryId === selectedCategory : true;
            return matchesSearch && matchesCategory;
        });
    }, [services, searchTerm, selectedCategory]);

    // Reset page when filter changes
    React.useEffect(() => {
        setCurrentPage(1);
    }, [searchTerm, selectedCategory]);

    // Calculate pagination slice
    const indexOfLastItem = currentPage * itemsPerPage;
    const indexOfFirstItem = indexOfLastItem - itemsPerPage;
    const currentServices = filteredServices.slice(indexOfFirstItem, indexOfLastItem);
    const totalPages = Math.ceil(filteredServices.length / itemsPerPage);

    // Pagination Handlers
    const paginate = (pageNumber) => setCurrentPage(pageNumber);

    // Handlers
    const handleOpenModal = (service = null) => {
        setEditingService(service);
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setEditingService(null);
    };

    const handleViewService = (service) => {
        setViewingService(service);
        setIsDetailModalOpen(true);
    };

    const handleCloseDetailModal = () => {
        setIsDetailModalOpen(false);
        setViewingService(null);
    };

    const handleSubmit = async (formData) => {
        let result;
        if (editingService) {
            result = await updateService(editingService.id, formData);
        } else {
            result = await addService(formData);
        }

        if (result.success) {
            handleCloseModal();
            // Optional: Show toast success
        } else {
            alert('Có lỗi xảy ra: ' + result.error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Bạn có chắc chắn muốn xóa dịch vụ này? Hành động này không thể hoàn tác.')) {
            const result = await deleteService(id);
            if (!result.success) {
                alert('Có lỗi xảy ra khi xóa: ' + result.error);
            }
        }
    };

    const handleToggleStatus = async (service) => {
        const result = await toggleServiceStatus(service);
        if (!result.success) {
            alert('Có lỗi xảy ra khi cập nhật trạng thái: ' + result.error);
        }
    };

    const isLoading = servicesLoading || categoriesLoading;

    return (
        <div className="p-6 bg-gray-50 min-h-screen font-sans">
            {/* Page Header */}
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800 flex items-center gap-3">
                        <span className="bg-white p-2 rounded-xl shadow-sm border border-gray-100 text-[#4CAE4F]">
                            <FaBroom />
                        </span>
                        Quản lý Dịch vụ
                    </h1>
                    <p className="text-gray-500 mt-1 ml-14">
                        Quản lý danh sách các gói dịch vụ và bảng giá cung cấp cho khách hàng.
                    </p>
                </div>
                <button
                    onClick={() => handleOpenModal()}
                    className="flex items-center justify-center gap-2 h-11 px-6 text-sm font-semibold rounded-xl bg-[#4CAE4F] text-white hover:bg-[#439c47] hover:shadow-lg hover:shadow-green-200 transition-all active:scale-95"
                >
                    <FaPlus className="text-base" />
                    Thêm Dịch vụ Mới
                </button>
            </div>

            {/* Main Content Card */}
            <div className="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                {/* Filters */}
                <ServiceFilters
                    searchTerm={searchTerm}
                    onSearchChange={setSearchTerm}
                    selectedCategory={selectedCategory}
                    onCategoryChange={setSelectedCategory}
                    categories={categories}
                />

                {/* Table */}
                {isLoading ? (
                    <div className="flex flex-col items-center justify-center py-20">
                        <div className="w-10 h-10 border-4 border-[#4CAE4F] border-t-transparent rounded-full animate-spin mb-4"></div>
                        <p className="text-gray-500 font-medium">Đang tải dữ liệu...</p>
                    </div>
                ) : (
                    <ServiceTable
                        services={currentServices}
                        categories={categories}
                        onEdit={handleOpenModal}
                        onDelete={handleDelete}
                        onToggleStatus={handleToggleStatus}
                        onView={handleViewService}
                    />
                )}





                {/* Pagination */}
                {filteredServices.length > 0 && (
                    <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex flex-col md:flex-row justify-between items-center gap-4 text-sm text-gray-500">
                        <div className="font-medium">
                            Hiển thị {indexOfFirstItem + 1}-{Math.min(indexOfLastItem, filteredServices.length)} trong tổng số {filteredServices.length} dịch vụ
                        </div>

                        <div className="flex items-center gap-2">
                            <button
                                onClick={() => paginate(currentPage - 1)}
                                disabled={currentPage === 1}
                                className={`px-3 py-1 rounded-lg border ${currentPage === 1 ? 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed' : 'bg-white text-gray-600 border-gray-300 hover:bg-gray-50'}`}
                            >
                                Trước
                            </button>

                            {[...Array(totalPages)].map((_, index) => (
                                <button
                                    key={index}
                                    onClick={() => paginate(index + 1)}
                                    className={`w-8 h-8 flex items-center justify-center rounded-lg border ${currentPage === index + 1
                                        ? 'bg-[#4CAE4F] text-white border-[#4CAE4F]'
                                        : 'bg-white text-gray-600 border-gray-300 hover:bg-gray-50'
                                        }`}
                                >
                                    {index + 1}
                                </button>
                            ))}

                            <button
                                onClick={() => paginate(currentPage + 1)}
                                disabled={currentPage === totalPages}
                                className={`px-3 py-1 rounded-lg border ${currentPage === totalPages ? 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed' : 'bg-white text-gray-600 border-gray-300 hover:bg-gray-50'}`}
                            >
                                Sau
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {/* Edit/Add Modal */}
            <ServiceModal
                isOpen={isModalOpen}
                onClose={handleCloseModal}
                onSubmit={handleSubmit}
                editingService={editingService}
                categories={categories}
            />

            {/* View Detail Modal */}
            <ServiceDetailModal
                isOpen={isDetailModalOpen}
                onClose={handleCloseDetailModal}
                service={viewingService}
                categories={categories}
            />
        </div>
    );

};

export default ServiceManager;
