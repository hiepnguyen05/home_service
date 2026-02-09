import React, { useState, useEffect } from 'react';
import { getProviderRequestDetails } from '../../services/providerService';

const ProviderModal = ({ isOpen, onClose, onSubmit, provider, isEditing, viewMode = false, serviceMap = {} }) => {
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phoneNumber: '',
        role: 'provider',
        isActive: true,
        isVerified: true,
        avatar_url: '',
        bio: '',
        experience: '',
        address: '',
        idCardImages: [], // Danh sách URL ảnh CCCD
        workImages: [],    // Danh sách URL ảnh công việc
        serviceIds: []    // Danh sách ID dịch vụ
    });

    useEffect(() => {
        const fetchDetails = async () => {
            if (provider && (isEditing || viewMode)) {
                // Initialize with available provider data
                let initialData = {
                    full_name: provider.full_name || provider.name || provider.displayName || '',
                    email: provider.email || '',
                    phoneNumber: provider.phoneNumber || provider.phone || '',
                    role: 'provider',
                    isActive: provider.isActive !== undefined ? provider.isActive : true,
                    isVerified: provider.isVerified !== undefined ? provider.isVerified : false,
                    avatar_url: provider.avatar_url || provider.avatarUrl || provider.photoURL || '',
                    bio: provider.bio || '',
                    experience: provider.experience || '',
                    address: provider.address || '',
                    idCardImages: provider.idCardImages || [],
                    workImages: provider.workImages || [],
                    serviceIds: provider.serviceIds || []
                };

                // Fetch extra details from partner_requests if needed (especially for images)
                // We do this if it's view mode or editing to ensure we have the latest docs
                try {
                    const requestDetails = await getProviderRequestDetails(provider.id);
                    if (requestDetails) {
                        // Merge images from request details
                        const idImages = [];
                        if (requestDetails.idFrontUrl) idImages.push(requestDetails.idFrontUrl);
                        if (requestDetails.idBackUrl) idImages.push(requestDetails.idBackUrl);
                        // Also check provider object fallbacks
                        if (provider.idFrontUrl && !idImages.includes(provider.idFrontUrl)) idImages.push(provider.idFrontUrl);
                        if (provider.idBackUrl && !idImages.includes(provider.idBackUrl)) idImages.push(provider.idBackUrl);
                        if (provider.idCardImages && Array.isArray(provider.idCardImages)) idImages.push(...provider.idCardImages);

                        const workImgs = [];
                        if (requestDetails.certificates && Array.isArray(requestDetails.certificates)) {
                            workImgs.push(...requestDetails.certificates);
                        }
                        // Also check provider object fallbacks
                        if (provider.certificates && Array.isArray(provider.certificates)) workImgs.push(...provider.certificates);
                        if (provider.certificateUrl) workImgs.push(provider.certificateUrl);
                        if (provider.workImages && Array.isArray(provider.workImages)) workImgs.push(...provider.workImages);

                        initialData.idCardImages = [...new Set(idImages)];
                        initialData.workImages = [...new Set(workImgs)];

                        // Sync services if provider object doesn't have them but request does
                        if ((!initialData.serviceIds || initialData.serviceIds.length === 0) && requestDetails.services && Array.isArray(requestDetails.services)) {
                            initialData.serviceIds = requestDetails.services.map(s => s.serviceId || s.id);
                        }

                        // Can also sync other fields if missing in provider but present in request
                        if (!initialData.experience) {
                            if (requestDetails.experienceYears) {
                                initialData.experience = `${requestDetails.experienceYears} năm`;
                            } else if (requestDetails.experience) {
                                initialData.experience = requestDetails.experience;
                            }
                        }

                        if (!initialData.bio && requestDetails.bio) initialData.bio = requestDetails.bio;
                    } else {
                        // Fallback purely to provider object if no request found
                        const idImages = [];
                        if (provider.idFrontUrl) idImages.push(provider.idFrontUrl);
                        if (provider.idBackUrl) idImages.push(provider.idBackUrl);
                        if (provider.idCardImages && Array.isArray(provider.idCardImages)) idImages.push(...provider.idCardImages);

                        const workImgs = [];
                        if (provider.certificates && Array.isArray(provider.certificates)) workImgs.push(...provider.certificates);
                        else if (provider.certificateUrl) workImgs.push(provider.certificateUrl);
                        if (provider.workImages && Array.isArray(provider.workImages)) workImgs.push(...provider.workImages);

                        initialData.idCardImages = [...new Set(idImages)];
                        initialData.workImages = [...new Set(workImgs)];
                    }
                } catch (err) {
                    console.error("Error fetching extra details", err);
                    // Fallback purely to provider object on error
                    const idImages = [];
                    if (provider.idFrontUrl) idImages.push(provider.idFrontUrl);
                    if (provider.idBackUrl) idImages.push(provider.idBackUrl);
                    if (provider.idCardImages && Array.isArray(provider.idCardImages)) idImages.push(...provider.idCardImages);

                    const workImgs = [];
                    if (provider.certificates && Array.isArray(provider.certificates)) workImgs.push(...provider.certificates);
                    else if (provider.certificateUrl) workImgs.push(provider.certificateUrl);
                    if (provider.workImages && Array.isArray(provider.workImages)) workImgs.push(...provider.workImages);

                    initialData.idCardImages = [...new Set(idImages)];
                    initialData.workImages = [...new Set(workImgs)];
                }

                setFormData(initialData);
            } else {
                setFormData({
                    full_name: '',
                    email: '',
                    phoneNumber: '',
                    role: 'provider',
                    isActive: true,
                    isVerified: true, // Admin tạo thì mặc định verify
                    avatar_url: '',
                    bio: '',
                    experience: '',
                    address: '',
                    idCardImages: [],
                    workImages: [],
                    serviceIds: []
                });
            }
        };

        fetchDetails();
    }, [provider, isEditing, viewMode, isOpen]);

    const handleChange = (e) => {
        if (viewMode) return;
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    // Helper to handle array inputs (comma separated for ID/Work images if needed, or just simple text for now if we want to keep it simple, 
    // but better to allow adding multiple URLs. For this iteration, let's use textarea for URLs separated by newline or comma)
    const handleArrayChange = (e, field) => {
        if (viewMode) return;
        const value = e.target.value;
        // Split by newline or comma and trim
        const array = value.split(/[\n,]+/).map(item => item.trim()).filter(item => item !== '');
        setFormData(prev => ({
            ...prev,
            [field]: array
        }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (viewMode) return;
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm overflow-y-auto">
            <div className="bg-white dark:bg-slate-900 rounded-xl shadow-xl w-full max-w-2xl mx-4 my-8 overflow-hidden animate-fade-in flex flex-col max-h-[90vh]">
                <div className="px-6 py-4 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between shrink-0">
                    <h3 className="text-lg font-bold text-slate-900 dark:text-white">
                        {viewMode ? 'Chi tiết thợ' : isEditing ? 'Cập nhật thông tin thợ' : 'Thêm thợ mới'}
                    </h3>
                    <button
                        onClick={onClose}
                        className="p-1 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-500 transition-colors"
                    >
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>

                <div className="flex-1 overflow-y-auto p-6 scrollbar-thin scrollbar-thumb-slate-300 dark:scrollbar-thumb-slate-600">
                    <form onSubmit={handleSubmit} className="space-y-6">

                        {/* Avatar Section - Moved to Top */}
                        <div className="flex flex-col items-center justify-center mb-6">
                            <div className="relative group">
                                <div className="w-32 h-32 rounded-full overflow-hidden border-4 border-slate-100 dark:border-slate-800 shadow-md">
                                    {formData.avatar_url ? (
                                        <img
                                            src={formData.avatar_url}
                                            alt="Avatar"
                                            className="w-full h-full object-cover"
                                            onError={(e) => {
                                                e.target.onerror = null;
                                                e.target.src = 'https://ui-avatars.com/api/?name=User&background=random';
                                            }}
                                        />
                                    ) : (
                                        <div className="w-full h-full bg-slate-200 dark:bg-slate-700 flex items-center justify-center text-slate-400">
                                            <span className="material-symbols-outlined text-4xl">person</span>
                                        </div>
                                    )}
                                </div>
                                {!viewMode && (
                                    <div className="mt-4 w-full max-w-xs">
                                        <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1 text-center">
                                            Avatar URL
                                        </label>
                                        <input
                                            type="url"
                                            name="avatar_url"
                                            value={formData.avatar_url}
                                            onChange={handleChange}
                                            className="w-full px-3 py-2 text-sm bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all text-center"
                                            placeholder="https://example.com/avatar.jpg"
                                        />
                                    </div>
                                )}
                            </div>
                        </div>

                        {/* Basic Info Section */}
                        <div className="space-y-4">
                            <h4 className="font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-800 pb-2">Thông tin cơ bản</h4>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                        Họ và tên <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="text"
                                        name="full_name"
                                        required
                                        disabled={viewMode}
                                        value={formData.full_name}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                        placeholder="Nhập họ và tên thợ"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                        Số điện thoại
                                    </label>
                                    <input
                                        type="tel"
                                        name="phoneNumber"
                                        disabled={viewMode}
                                        value={formData.phoneNumber}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                        placeholder="0901234567"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                        Email <span className="text-red-500">*</span>
                                    </label>
                                    <input
                                        type="email"
                                        name="email"
                                        required
                                        disabled={viewMode}
                                        value={formData.email}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                        placeholder="example@email.com"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                        Địa chỉ
                                    </label>
                                    <input
                                        type="text"
                                        name="address"
                                        disabled={viewMode}
                                        value={formData.address}
                                        onChange={handleChange}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                        placeholder="Địa chỉ liên hệ"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Services Section */}
                        <div className="space-y-4">
                            <h4 className="font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-800 pb-2">Dịch vụ cung cấp</h4>
                            <div>
                                {formData.serviceIds && formData.serviceIds.length > 0 ? (
                                    <div className="flex flex-wrap gap-2">
                                        {formData.serviceIds.map((sid, index) => (
                                            <span key={index} className="px-3 py-1 bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400 rounded-full text-sm font-medium border border-green-200 dark:border-green-800">
                                                {serviceMap[sid] || sid}
                                            </span>
                                        ))}
                                    </div>
                                ) : (
                                    <p className="text-sm text-slate-500 italic">Chưa đăng ký dịch vụ nào</p>
                                )}
                            </div>
                        </div>

                        {/* Detailed Info Section */}
                        <div className="space-y-4">
                            <h4 className="font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-800 pb-2">Kinh nghiệm & Mô tả</h4>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                    Kinh nghiệm (Năm/Mô tả ngắn)
                                </label>
                                <input
                                    type="text"
                                    name="experience"
                                    disabled={viewMode}
                                    value={formData.experience}
                                    onChange={handleChange}
                                    className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                    placeholder="Ví dụ: 5 năm kinh nghiệm sửa điện lạnh"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                    Giới thiệu bản thân (Bio)
                                </label>
                                <textarea
                                    name="bio"
                                    disabled={viewMode}
                                    value={formData.bio}
                                    onChange={handleChange}
                                    rows="4"
                                    className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all disabled:opacity-70 disabled:cursor-not-allowed"
                                    placeholder="Mô tả chi tiết về kỹ năng, phong cách làm việc..."
                                ></textarea>
                            </div>
                        </div>

                        {/* Images Section */}
                        <div className="space-y-4">
                            <h4 className="font-semibold text-slate-900 dark:text-white border-b border-slate-200 dark:border-slate-800 pb-2">Hình ảnh & Hồ sơ</h4>

                            {/* Removed separate Avatar input here since it's moved to top */}

                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                    Ảnh CCCD/CMND (Mặt trước/Mặt sau)
                                    {!viewMode && <span className="text-xs font-normal text-slate-500 italic ml-2">(Nhập mỗi URL một dòng)</span>}
                                </label>
                                {viewMode ? (
                                    <div className="flex flex-wrap gap-2 mt-2">
                                        {formData.idCardImages && formData.idCardImages.length > 0 ? (
                                            formData.idCardImages.map((url, index) => (
                                                <a key={index} href={url} target="_blank" rel="noopener noreferrer" className="block w-40 h-24 overflow-hidden rounded-lg border border-slate-200 hover:opacity-80 transition-opacity bg-slate-100">
                                                    <img src={url} alt={`CCCD ${index + 1}`} className="w-full h-full object-cover" onError={(e) => { e.target.style.display = 'none'; }} />
                                                </a>
                                            ))
                                        ) : (
                                            <p className="text-sm text-slate-500 italic">Chưa cập nhật ảnh CCCD</p>
                                        )}
                                    </div>
                                ) : (
                                    <textarea
                                        rows="3"
                                        defaultValue={formData.idCardImages.join('\n')}
                                        onChange={(e) => handleArrayChange(e, 'idCardImages')}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all"
                                        placeholder="Link ảnh mặt trước&#10;Link ảnh mặt sau..."
                                    ></textarea>
                                )}
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-1">
                                    Ảnh bằng cấp/Chứng chỉ/Công việc (Certificates)
                                    {!viewMode && <span className="text-xs font-normal text-slate-500 italic ml-2">(Nhập mỗi URL một dòng)</span>}
                                </label>
                                {viewMode ? (
                                    <div className="flex flex-wrap gap-2 mt-2">
                                        {formData.workImages && formData.workImages.length > 0 ? (
                                            formData.workImages.map((url, index) => (
                                                <a key={index} href={url} target="_blank" rel="noopener noreferrer" className="block w-24 h-24 overflow-hidden rounded-lg border border-slate-200 hover:opacity-80 transition-opacity bg-slate-100">
                                                    <img src={url} alt={`Cert/Work ${index + 1}`} className="w-full h-full object-cover" onError={(e) => { e.target.style.display = 'none'; }} />
                                                </a>
                                            ))
                                        ) : (
                                            <p className="text-sm text-slate-500 italic">Chưa cập nhật ảnh chứng chỉ/công việc</p>
                                        )}
                                    </div>
                                ) : (
                                    <textarea
                                        rows="3"
                                        defaultValue={formData.workImages.join('\n')}
                                        onChange={(e) => handleArrayChange(e, 'workImages')}
                                        className="w-full px-3 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 outline-none transition-all"
                                        placeholder="Link chứng chỉ 1&#10;Link hình ảnh công việc..."
                                    ></textarea>
                                )}
                            </div>
                        </div>

                        {/* Status Section */}
                        <div className="space-y-4 pt-2 border-t border-slate-200 dark:border-slate-800">
                            <h4 className="font-semibold text-slate-900 dark:text-white">Trạng thái</h4>
                            <div className="flex flex-col gap-2">
                                <div className="flex items-center gap-2">
                                    <input
                                        type="checkbox"
                                        name="isActive"
                                        id="isActive"
                                        disabled={viewMode}
                                        checked={formData.isActive}
                                        onChange={handleChange}
                                        className="w-4 h-4 text-green-600 bg-slate-100 border-slate-300 rounded focus:ring-green-500 dark:focus:ring-green-600 dark:ring-offset-slate-800 focus:ring-2 dark:bg-slate-700 dark:border-slate-600 disabled:opacity-70 disabled:cursor-not-allowed"
                                    />
                                    <label htmlFor="isActive" className="text-sm font-medium text-slate-700 dark:text-slate-300 cursor-pointer disabled:cursor-not-allowed">
                                        Trạng thái hoạt động (Active)
                                    </label>
                                </div>

                                <div className="flex items-center gap-2">
                                    <input
                                        type="checkbox"
                                        name="isVerified"
                                        id="isVerified"
                                        disabled={viewMode}
                                        checked={formData.isVerified}
                                        onChange={handleChange}
                                        className="w-4 h-4 text-blue-600 bg-slate-100 border-slate-300 rounded focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-slate-800 focus:ring-2 dark:bg-slate-700 dark:border-slate-600 disabled:opacity-70 disabled:cursor-not-allowed"
                                    />
                                    <label htmlFor="isVerified" className="text-sm font-medium text-slate-700 dark:text-slate-300 cursor-pointer disabled:cursor-not-allowed">
                                        Đã xác minh (Verified)
                                    </label>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>

                <div className="px-6 py-4 border-t border-slate-200 dark:border-slate-800 flex justify-end gap-3 bg-slate-50 dark:bg-slate-800/50 shrink-0">
                    <button
                        type="button"
                        onClick={onClose}
                        className="px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 hover:bg-slate-50 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-600 dark:hover:bg-slate-700 rounded-lg transition-colors"
                    >
                        {viewMode ? 'Đóng' : 'Hủy bỏ'}
                    </button>
                    {!viewMode && (
                        <button
                            onClick={handleSubmit}
                            className="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 rounded-lg shadow-lg shadow-green-500/20 transition-all transform active:scale-95"
                        >
                            {isEditing ? 'Lưu thay đổi' : 'Thêm thợ'}
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ProviderModal;
