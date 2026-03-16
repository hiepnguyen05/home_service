import React, { useState } from "react";
import { FaPlus, FaSearch, FaImages, FaCog } from "react-icons/fa";
import { useBanners } from "../../hooks/useBanners";
import BannerTable from "./components/BannerTable";
import BannerModal from "./components/BannerModal";

const SettingsManager = () => {
    const { 
        banners, 
        loading, 
        error, 
        addBanner, 
        updateBanner, 
        deleteBanner, 
        toggleBannerStatus,
        uploadImage 
    } = useBanners();

    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingBanner, setEditingBanner] = useState(null);
    const [activeTab, setActiveTab] = useState("banners");

    const handleOpenModal = (banner = null) => {
        setEditingBanner(banner);
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setEditingBanner(null);
    };

    const handleSubmit = async (formData) => {
        let result;
        if (editingBanner) {
            result = await updateBanner(editingBanner.id, formData);
        } else {
            result = await addBanner(formData);
        }

        if (result.success) {
            handleCloseModal();
        } else {
            alert("Có lỗi xảy ra: " + result.error);
        }
    };

    const handleDelete = async (id, title) => {
        if (window.confirm(`Bạn có chắc chắn muốn xóa banner "${title}" không?`)) {
            const result = await deleteBanner(id);
            if (!result.success) {
                alert("Lỗi khi xóa: " + result.error);
            }
        }
    };



    return (
        <div className="p-8 bg-slate-50 dark:bg-slate-900 min-h-screen">
            {/* Header */}
            <div className="flex flex-col md:flex-row justify-between items-start mb-8 gap-4">
                <div>
                    <h1 className="text-3xl font-black text-slate-800 dark:text-slate-100 tracking-tight">Cài đặt hệ thống</h1>
                    <p className="text-slate-500 mt-1 font-medium">Cấu hình tham số và nội dung hiển thị trên ứng dụng</p>
                </div>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 mb-8 bg-white dark:bg-slate-800 p-1.5 rounded-2xl border border-slate-200 dark:border-slate-700 w-fit shadow-sm">
                <button 
                    onClick={() => setActiveTab("banners")}
                    className={`flex items-center gap-2 px-6 py-2.5 rounded-xl transition-all font-bold text-sm ${activeTab === 'banners' ? 'bg-[#4CAE4F] text-white shadow-lg shadow-green-200' : 'text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-700'}`}
                >
                    <FaImages /> Quản lý Banner
                </button>
                <button 
                    onClick={() => setActiveTab("general")}
                    className={`flex items-center gap-2 px-6 py-2.5 rounded-xl transition-all font-bold text-sm ${activeTab === 'general' ? 'bg-[#4CAE4F] text-white shadow-lg shadow-green-200' : 'text-slate-500 hover:bg-slate-50 dark:hover:bg-slate-700'}`}
                >
                    <FaCog /> Cấu hình chung
                </button>
            </div>

            {activeTab === "banners" && (
                <div className="space-y-6 animate-in slide-in-from-bottom-4 duration-500">
                    {/* Banner Control Bar */}
                    <div className="flex flex-col md:flex-row justify-end items-center gap-4 bg-white dark:bg-slate-800 p-4 rounded-2xl border border-slate-200 dark:border-slate-700 shadow-sm">
                        <button
                            onClick={() => handleOpenModal()}
                            className="flex items-center gap-2 bg-[#4CAE4F] text-white px-6 py-3 rounded-xl hover:bg-[#439c47] transition-all shadow-lg shadow-green-200 hover:shadow-xl hover:-translate-y-0.5 font-bold w-full md:w-auto"
                        >
                            <FaPlus />
                            <span>Thêm Banner Mới</span>
                        </button>
                    </div>

                    {/* Loading/Error State */}
                    {error && (
                        <div className="bg-red-50 text-red-600 p-4 rounded-2xl border border-red-100 flex items-center gap-3 font-medium">
                            <span className="material-symbols-outlined">error</span> {error}
                        </div>
                    )}

                    {loading ? (
                        <div className="flex flex-col items-center justify-center py-20 bg-white rounded-2xl border border-slate-100">
                            <div className="w-12 h-12 border-4 border-green-500 border-t-transparent rounded-full animate-spin mb-4"></div>
                            <p className="text-slate-500 font-medium animate-pulse">Đang tải danh sách banner...</p>
                        </div>
                    ) : (
                        <BannerTable
                            banners={banners}
                            onEdit={handleOpenModal}
                            onDelete={handleDelete}
                            onToggleStatus={toggleBannerStatus}
                        />
                    )}
                </div>
            )}

            {activeTab === "general" && (
                <div className="bg-white dark:bg-slate-800 p-12 rounded-3xl border border-dashed border-slate-300 dark:border-slate-700 text-center animate-in fade-in duration-500">
                    <div className="size-16 rounded-full bg-slate-50 dark:bg-slate-900 flex items-center justify-center mx-auto mb-4">
                        <FaCog className="text-slate-400 animate-spin-slow" size={24} />
                    </div>
                    <h3 className="text-lg font-bold text-slate-800 dark:text-slate-200">Cấu hình hệ thống</h3>
                    <p className="text-slate-500 max-w-sm mx-auto mt-2">Tính năng đang được phát triển. Vui lòng quay lại sau!</p>
                </div>
            )}

            {/* Modal */}
            <BannerModal
                isOpen={isModalOpen}
                onClose={handleCloseModal}
                onSubmit={handleSubmit}
                editingBanner={editingBanner}
                nextOrder={banners.length > 0 ? Math.max(...banners.map(b => b.order || 0)) + 1 : 1}
                onUpload={uploadImage}
            />
        </div>
    );
};

export default SettingsManager;
