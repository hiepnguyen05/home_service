import React, { useState, useEffect, useRef } from 'react';
import { FaTimes, FaImage, FaSortAmountUp, FaCloudUploadAlt, FaSpinner, FaCheck } from 'react-icons/fa';

const BannerModal = ({ isOpen, onClose, onSubmit, editingBanner, nextOrder, onUpload }) => {
    const initialState = {
        imageUrl: '',
        order: nextOrder,
        isActive: true
    };

    const [formData, setFormData] = useState(initialState);
    const [previewUrl, setPreviewUrl] = useState('');
    const [uploading, setUploading] = useState(false);
    const fileInputRef = useRef(null);

    useEffect(() => {
        if (editingBanner) {
            setFormData({
                imageUrl: editingBanner.imageUrl || '',
                order: editingBanner.order || nextOrder,
                isActive: editingBanner.isActive ?? true
            });
            setPreviewUrl(editingBanner.imageUrl || '');
        } else {
            setFormData({ ...initialState, order: nextOrder });
            setPreviewUrl('');
        }
    }, [editingBanner, nextOrder, isOpen]);

    const handleFileChange = async (e) => {
        const file = e.target.files[0];
        if (!file) return;

        // Preview local file
        const localUrl = URL.createObjectURL(file);
        setPreviewUrl(localUrl);

        // Upload to Cloudinary
        setUploading(true);
        try {
            const result = await onUpload(file);
            setUploading(false);

            if (result.success) {
                setFormData(prev => ({ ...prev, imageUrl: result.url }));
                setPreviewUrl(result.url);
            } else {
                alert('Lỗi tải ảnh: ' + result.error);
                setPreviewUrl(editingBanner?.imageUrl || '');
            }
        } catch (error) {
            setUploading(false);
            alert('Lỗi: ' + error.message);
        }
    };

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!formData.imageUrl) {
            alert('Vui lòng tải lên hình ảnh banner');
            return;
        }
        onSubmit(formData);
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center z-[100] p-4">
            <div className="bg-white dark:bg-slate-900 rounded-3xl shadow-2xl w-full max-w-md overflow-hidden animate-in fade-in zoom-in duration-300 border border-slate-200 dark:border-slate-800">
                {/* Header */}
                <div className="px-6 py-4 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center bg-slate-50/50 dark:bg-slate-800/50">
                    <div className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center text-[#4CAE4F]">
                            <FaImage size={16} />
                        </div>
                        <h2 className="text-lg font-bold text-slate-800 dark:text-slate-100">
                            {editingBanner ? 'Cập nhật Banner' : 'Thêm Banner Mới'}
                        </h2>
                    </div>
                    <button onClick={onClose} className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all">
                        <FaTimes size={18} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Upload Section */}
                    <div className="space-y-4">
                        <label className="text-sm font-semibold text-slate-700 dark:text-slate-300">Hình ảnh banner</label>
                        
                        <div 
                            onClick={() => fileInputRef.current?.click()}
                            className={`relative aspect-[2/1] w-full rounded-2xl border-2 border-dashed transition-all cursor-pointer flex flex-col items-center justify-center overflow-hidden
                                ${previewUrl ? 'border-[#4CAE4F] bg-green-50/10' : 'border-slate-200 dark:border-slate-700 hover:border-[#4CAE4F] bg-slate-50 dark:bg-slate-800/50'}`}
                        >
                            {previewUrl ? (
                                <>
                                    <img src={previewUrl} alt="Preview" className="w-full h-full object-cover" />
                                    <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity">
                                        <FaCloudUploadAlt className="text-white text-3xl" />
                                        <span className="text-white font-bold ml-2">Đổi hình ảnh</span>
                                    </div>
                                </>
                            ) : (
                                <div className="text-center p-4">
                                    <FaCloudUploadAlt className="text-slate-400 text-4xl mb-2 mx-auto" />
                                    <p className="text-sm text-slate-500 font-medium">Nhấn để tải ảnh lên Cloudinary</p>
                                    <p className="text-xs text-slate-400 mt-1">Hỗ trợ JPG, PNG (Khuyên dùng 1200x600)</p>
                                </div>
                            )}

                            {uploading && (
                                <div className="absolute inset-0 bg-white/90 dark:bg-slate-900/90 flex flex-col items-center justify-center z-10">
                                    <FaSpinner className="text-[#4CAE4F] animate-spin text-3xl mb-2" />
                                    <p className="text-xs font-bold text-[#4CAE4F] uppercase tracking-widest">Đang tải lên...</p>
                                </div>
                            )}
                        </div>
                        <input 
                            type="file" 
                            ref={fileInputRef} 
                            onChange={handleFileChange} 
                            accept="image/*" 
                            className="hidden" 
                        />
                    </div>

                    <div className="grid grid-cols-1 gap-6">
                        {/* Order */}
                        <div className="space-y-2">
                            <label className="text-sm font-semibold text-slate-700 dark:text-slate-300 flex items-center gap-2">
                                <FaSortAmountUp className="text-blue-500" /> Thứ tự hiển thị
                            </label>
                            <input
                                type="number"
                                name="order"
                                value={formData.order}
                                onChange={handleChange}
                                className="w-full px-4 py-3 rounded-xl border border-slate-200 dark:border-slate-700 dark:bg-slate-800 outline-none focus:ring-4 focus:ring-[#4CAE4F]/10 focus:border-[#4CAE4F] transition-all font-bold"
                            />
                        </div>

                        {/* Status Switch */}
                        <div 
                            className={`flex items-center justify-between p-4 rounded-xl border transition-all cursor-pointer shadow-sm
                                ${formData.isActive ? 'border-green-200 bg-green-50/30' : 'border-slate-200 bg-slate-50/30'}`}
                            onClick={() => setFormData(prev => ({ ...prev, isActive: !prev.isActive }))}
                        >
                            <div className="flex items-center gap-3">
                                <div className={`w-10 h-10 rounded-full flex items-center justify-center ${formData.isActive ? 'bg-green-100 text-green-600' : 'bg-slate-200 text-slate-400'}`}>
                                    <FaCheck size={14} />
                                </div>
                                <div>
                                    <p className="text-sm font-bold text-slate-800 dark:text-slate-200">Kích hoạt banner</p>
                                    <p className="text-[10px] text-slate-500">Banner sẽ được hiển thị cho khách hàng</p>
                                </div>
                            </div>
                            <div className={`w-12 h-6 rounded-full relative transition-all duration-300 ${formData.isActive ? 'bg-[#4CAE4F]' : 'bg-slate-300'}`}>
                                <div className={`absolute top-1 left-1 w-4 h-4 bg-white rounded-full shadow-md transition-all duration-300 ${formData.isActive ? 'translate-x-6' : 'translate-x-0'}`}></div>
                            </div>
                        </div>
                    </div>

                    {/* Footer Actions */}
                    <div className="flex gap-3 pt-4 border-t border-slate-100 dark:border-slate-800">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-4 py-3.5 border border-slate-200 dark:border-slate-700 text-slate-600 dark:text-slate-400 rounded-xl hover:bg-slate-50 dark:hover:bg-slate-800 font-bold transition-all text-sm"
                        >
                            Hủy
                        </button>
                        <button
                            type="submit"
                            disabled={uploading || !formData.imageUrl}
                            className={`flex-[2] px-4 py-3.5 bg-[#4CAE4F] text-white rounded-xl font-bold shadow-lg transition-all text-sm flex items-center justify-center gap-2
                                ${uploading || !formData.imageUrl ? 'opacity-50 cursor-not-allowed' : 'hover:bg-[#439c47] hover:-translate-y-0.5 shadow-green-200'}`}
                        >
                            <FaCheck />
                            {editingBanner ? 'Lưu thay đổi' : 'Xác nhận tạo'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default BannerModal;
