import React, { useState, useEffect } from 'react';

const CustomerModal = ({ isOpen, onClose, onSubmit, customer, isEditing, viewMode }) => {
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phoneNumber: '',
        role: 'customer',
        isActive: true,
        avatar_url: ''
    });

    useEffect(() => {
        if (customer && (isEditing || viewMode)) {
            setFormData({
                full_name: customer.full_name || customer.name || customer.displayName || '',
                email: customer.email || '',
                phoneNumber: customer.phoneNumber || customer.phone || '',
                role: customer.role || 'customer',
                isActive: customer.isActive !== undefined ? customer.isActive : true,
                avatar_url: customer.avatar_url || customer.avatarUrl || customer.photoURL || ''
            });
        } else {
            setFormData({
                full_name: '',
                email: '',
                phoneNumber: '',
                role: 'customer',
                isActive: true,
                avatar_url: ''
            });
        }
    }, [customer, isEditing, viewMode, isOpen]);

    const handleChange = (e) => {
        if (viewMode) return;
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (viewMode) {
            onClose();
            return;
        }
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm p-4">
            <div className="bg-white dark:bg-slate-900 rounded-3xl shadow-2xl w-full max-w-xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
                <div className="px-8 py-6 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between bg-slate-50/50 dark:bg-slate-800/30">
                    <div className="flex items-center gap-3">
                        <div className={`size-10 rounded-2xl flex items-center justify-center text-white shadow-lg ${viewMode ? 'bg-blue-500 shadow-blue-500/20' : isEditing ? 'bg-amber-500 shadow-amber-500/20' : 'bg-green-600 shadow-green-500/20'}`}>
                            <span className="material-symbols-outlined font-bold">
                                {viewMode ? 'visibility' : isEditing ? 'edit' : 'person_add'}
                            </span>
                        </div>
                        <div>
                            <h3 className="text-xl font-black text-slate-900 dark:text-white uppercase tracking-tight">
                                {viewMode ? 'Chi tiết khách hàng' : isEditing ? 'Cập nhật thông tin' : 'Thêm khách hàng'}
                            </h3>
                            <p className="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">
                                {viewMode ? 'Chế độ chỉ xem' : 'Vui lòng điền đầy đủ thông tin'}
                            </p>
                        </div>
                    </div>
                    <button
                        onClick={onClose}
                        className="size-10 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-600 transition-all flex items-center justify-center active:scale-95"
                    >
                        <span className="material-symbols-outlined">close</span>
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-8 space-y-6">
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div className="md:col-span-2">
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Họ và tên đầy đủ
                            </label>
                            <input
                                type="text"
                                name="full_name"
                                required
                                disabled={viewMode}
                                value={formData.full_name}
                                onChange={handleChange}
                                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-2xl focus:ring-4 focus:ring-green-500/10 focus:border-green-500 outline-none transition-all font-semibold text-slate-900 dark:text-white disabled:opacity-70 disabled:bg-slate-100 dark:disabled:bg-slate-900"
                                placeholder="VD: Nguyễn Văn A"
                            />
                        </div>

                        <div>
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Địa chỉ Email
                            </label>
                            <input
                                type="email"
                                name="email"
                                required
                                disabled={viewMode}
                                value={formData.email}
                                onChange={handleChange}
                                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-2xl focus:ring-4 focus:ring-green-500/10 focus:border-green-500 outline-none transition-all font-semibold text-slate-900 dark:text-white disabled:opacity-70 disabled:bg-slate-100 dark:disabled:bg-slate-900"
                                placeholder="abc@gmail.com"
                            />
                        </div>

                        <div>
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Số điện thoại
                            </label>
                            <input
                                type="tel"
                                name="phoneNumber"
                                disabled={viewMode}
                                value={formData.phoneNumber}
                                onChange={handleChange}
                                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-2xl focus:ring-4 focus:ring-green-500/10 focus:border-green-500 outline-none transition-all font-semibold text-slate-900 dark:text-white disabled:opacity-70 disabled:bg-slate-100 dark:disabled:bg-slate-900"
                                placeholder="09xxxxxxx"
                            />
                        </div>

                        <div>
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Vai trò người dùng
                            </label>
                            <select
                                name="role"
                                disabled={viewMode}
                                value={formData.role}
                                onChange={handleChange}
                                className="w-full px-4 py-3 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-2xl focus:ring-4 focus:ring-green-500/10 focus:border-green-500 outline-none transition-all font-semibold text-slate-900 dark:text-white disabled:opacity-70 disabled:bg-slate-100 dark:disabled:bg-slate-900 cursor-pointer appearance-none"
                            >
                                <option value="customer">Khách hàng</option>
                                <option value="provider">Nhà cung cấp</option>
                                <option value="admin">Quản trị viên</option>
                            </select>
                        </div>

                        <div>
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Trạng thái hoạt động
                            </label>
                            <div 
                                onClick={() => !viewMode && handleChange({ target: { name: 'isActive', type: 'checkbox', checked: !formData.isActive }})}
                                className={`flex items-center gap-3 px-4 py-3 rounded-2xl border transition-all cursor-pointer ${formData.isActive ? 'bg-green-50 border-green-100 dark:bg-green-900/10 dark:border-green-800' : 'bg-red-50 border-red-100 dark:bg-red-900/10 dark:border-red-800'} ${viewMode ? 'opacity-70 cursor-default' : ''}`}
                            >
                                <div className={`size-4 rounded-full border-2 ${formData.isActive ? 'bg-green-500 border-green-200' : 'bg-red-500 border-red-200'}`}></div>
                                <span className={`text-sm font-bold ${formData.isActive ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'}`}>
                                    {formData.isActive ? 'Đang hoạt động' : 'Đang bị khóa'}
                                </span>
                            </div>
                        </div>

                        <div className="md:col-span-2">
                            <label className="block text-xs font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">
                                Đường dẫn Ảnh đại diện (URL)
                            </label>
                            <div className="flex gap-4">
                                <div className="size-12 rounded-xl bg-slate-100 dark:bg-slate-800 flex items-center justify-center overflow-hidden border border-slate-200 dark:border-slate-700 flex-shrink-0">
                                    {formData.avatar_url ? (
                                        <img src={formData.avatar_url} alt="" className="size-full object-cover" />
                                    ) : (
                                        <span className="material-symbols-outlined text-slate-300">image</span>
                                    )}
                                </div>
                                <input
                                    type="url"
                                    name="avatar_url"
                                    disabled={viewMode}
                                    value={formData.avatar_url}
                                    onChange={handleChange}
                                    className="flex-1 px-4 py-3 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-2xl focus:ring-4 focus:ring-green-500/10 focus:border-green-500 outline-none transition-all font-semibold text-slate-900 dark:text-white disabled:opacity-70 disabled:bg-slate-100 dark:disabled:bg-slate-900"
                                    placeholder="https://..."
                                />
                            </div>
                        </div>
                    </div>

                    <div className="pt-6 flex justify-end gap-3">
                        <button
                            type="button"
                            onClick={onClose}
                            className="px-6 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200 transition-colors uppercase tracking-widest"
                        >
                            {viewMode ? 'Đóng' : 'Hủy bỏ'}
                        </button>
                        {!viewMode && (
                            <button
                                type="submit"
                                className={`px-8 py-3 text-sm font-black text-white rounded-2xl shadow-xl transition-all transform active:scale-95 uppercase tracking-widest ${isEditing ? 'bg-amber-500 hover:bg-amber-600 shadow-amber-500/20' : 'bg-green-600 hover:bg-green-700 shadow-green-500/20'}`}
                            >
                                {isEditing ? 'Lưu thay đổi' : 'Tạo mới khách hàng'}
                            </button>
                        )}
                    </div>
                </form>
            </div>
        </div>
    );
};

export default CustomerModal;
