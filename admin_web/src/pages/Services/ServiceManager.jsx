import React, { useState, useEffect } from 'react';
import { useFirebase } from '../../context/FirebaseContext';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, query, orderBy, serverTimestamp } from 'firebase/firestore';
import IconPicker from "../../components/Form/IconPicker";
import { getIconComponent } from "../../constants/icons";
import './ServiceManager.css';

const ServiceManager = () => {
    const { firestore } = useFirebase();
    const [services, setServices] = useState([]);
    const [categories, setCategories] = useState([]); // List of categories
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [currentService, setCurrentService] = useState(null);

    // Form states matching FIRESTORE_SCHEMA.md
    const [formData, setFormData] = useState({
        name: '',
        categoryId: '',
        description: '',
        minPrice: '',
        maxPrice: '',
        suggestedPrice: '',
        priceUnit: 'lần',
        iconName: '',
        imageUrl: '',
        isActive: true
    });

    useEffect(() => {
        const fetchData = async () => {
            setLoading(true);
            await Promise.all([fetchServices(), fetchCategories()]);
            setLoading(false);
        };
        fetchData();
    }, []);

    const fetchCategories = async () => {
        try {
            const q = query(collection(firestore, 'categories'), orderBy('order', 'asc'));
            const querySnapshot = await getDocs(q);
            const cats = querySnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setCategories(cats);
        } catch (error) {
            console.error("Error fetching categories:", error);
        }
    };

    const fetchServices = async () => {
        try {
            const q = query(collection(firestore, 'services'), orderBy('createdAt', 'desc'));
            const querySnapshot = await getDocs(q);
            const servicesList = querySnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            setServices(servicesList);
        } catch (error) {
            console.error("Error fetching services: ", error);
        }
    };

    const handleOpenModal = (service = null) => {
        if (service) {
            setCurrentService(service);
            setFormData({
                name: service.name,
                categoryId: service.categoryId || '',
                description: service.description || '',
                minPrice: service.minPrice || '',
                maxPrice: service.maxPrice || '',
                suggestedPrice: service.suggestedPrice || '',
                priceUnit: service.priceUnit || 'lần',
                iconName: service.iconName || '',
                imageUrl: service.imageUrl || '',
                isActive: service.isActive !== undefined ? service.isActive : true
            });
        } else {
            setCurrentService(null);
            setFormData({
                name: '',
                categoryId: categories.length > 0 ? categories[0].id : '',
                description: '',
                minPrice: '',
                maxPrice: '',
                suggestedPrice: '',
                priceUnit: 'lần',
                iconName: '',
                imageUrl: '',
                isActive: true
            });
        }
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setCurrentService(null);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const dataToSave = {
                name: formData.name,
                categoryId: formData.categoryId,
                description: formData.description,
                minPrice: Number(formData.minPrice),
                maxPrice: Number(formData.maxPrice),
                suggestedPrice: Number(formData.suggestedPrice),
                priceUnit: formData.priceUnit,
                iconName: formData.iconName,
                imageUrl: formData.imageUrl,
                isActive: formData.isActive,
                updatedAt: serverTimestamp()
            };

            if (currentService) {
                // Update
                const serviceRef = doc(firestore, 'services', currentService.id);
                await updateDoc(serviceRef, dataToSave);
                alert('Cập nhật dịch vụ thành công!');
            } else {
                // Create
                dataToSave.createdAt = serverTimestamp();
                dataToSave.rating = 0;
                dataToSave.reviewCount = 0;
                await addDoc(collection(firestore, 'services'), dataToSave);
                alert('Thêm dịch vụ mới thành công!');
            }

            handleCloseModal();
            fetchServices();
        } catch (error) {
            console.error("Error saving service: ", error);
            alert("Có lỗi xảy ra khi lưu dịch vụ");
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('Bạn có chắc chắn muốn xóa dịch vụ này? Hành động này không thể hoàn tác.')) {
            try {
                await deleteDoc(doc(firestore, 'services', id));
                fetchServices();
            } catch (error) {
                console.error("Error deleting service: ", error);
            }
        }
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
    };

    // Helper to get category name
    const getCategoryName = (catId) => {
        const cat = categories.find(c => c.id === catId);
        return cat ? cat.name : 'Chưa phân loại';
    };

    const filteredServices = services.filter(service =>
        service.name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="p-6 bg-gray-50 min-h-screen">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
                <div>
                    <h2 className="text-2xl font-bold leading-tight tracking-tight text-gray-900">Quản lý Dịch vụ</h2>
                    <p className="text-sm text-gray-500">Quản lý danh sách các gói dịch vụ cung cấp.</p>
                </div>
                <button
                    onClick={() => handleOpenModal()}
                    className="flex items-center justify-center gap-2 h-10 px-4 text-sm font-semibold rounded-lg bg-blue-600 text-white hover:bg-blue-700 transition"
                >
                    <span className="material-symbols-outlined text-base font-bold">+</span>
                    Thêm Dịch vụ
                </button>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                {/* Search & Filter Bar */}
                <div className="p-4 border-b border-gray-100 flex gap-4">
                    <div className="relative flex-1 max-w-md">
                        <span className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">🔍</span>
                        <input
                            type="text"
                            placeholder="Tìm kiếm dịch vụ..."
                            className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                </div>

                {/* Table */}
                <div className="overflow-x-auto">
                    <table className="w-full text-sm text-left">
                        <thead className="text-xs text-gray-500 uppercase bg-gray-50">
                            <tr>
                                <th className="px-6 py-3">Tên Dịch vụ</th>
                                <th className="px-6 py-3">Danh mục</th>
                                <th className="px-6 py-3">Giá dịch vụ</th>
                                <th className="px-6 py-3">Icon</th>
                                <th className="px-6 py-3">Trạng thái</th>
                                <th className="px-6 py-3 text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            {loading ? (
                                <tr><td colSpan="6" className="text-center py-8">Đang tải dữ liệu...</td></tr>
                            ) : filteredServices.length === 0 ? (
                                <tr><td colSpan="6" className="text-center py-8 text-gray-500">Không tìm thấy dịch vụ nào.</td></tr>
                            ) : (
                                filteredServices.map(service => {
                                    const IconComp = getIconComponent(service.iconName);
                                    return (
                                        <tr key={service.id} className="border-b border-gray-100 hover:bg-gray-50 last:border-0">
                                            <td className="px-6 py-4">
                                                <div className="flex items-center gap-3">
                                                    {service.imageUrl ? (
                                                        <img src={service.imageUrl} alt="" className="w-10 h-10 rounded-lg object-cover bg-gray-100" />
                                                    ) : (
                                                        <div className="w-10 h-10 rounded-lg bg-blue-100 flex items-center justify-center text-blue-600 font-bold">
                                                            {service.name.charAt(0)}
                                                        </div>
                                                    )}
                                                    <div>
                                                        <div className="font-medium text-gray-900">{service.name}</div>
                                                        <div className="text-xs text-gray-500 truncate max-w-[200px]">{service.description}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 text-gray-600">
                                                <span className="bg-gray-100 px-2 py-1 rounded text-xs font-medium">
                                                    {getCategoryName(service.categoryId)}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4">
                                                <div className="flex flex-col text-sm">
                                                    <span className="font-bold text-blue-600">
                                                        {formatCurrency(service.suggestedPrice || 0)} / {service.priceUnit || 'lần'}
                                                    </span>
                                                    <span className="text-xs text-gray-500 mt-1">
                                                        {formatCurrency(service.minPrice || 0)} - {formatCurrency(service.maxPrice || 0)}
                                                    </span>
                                                </div>
                                            </td>
                                            <td className="px-6 py-4 font-mono text-xs text-gray-500">{service.iconName}</td>
                                            <td className="px-6 py-4">
                                                <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${service.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                                    {service.isActive ? 'Hiển thị' : 'Đã ẩn'}
                                                </span>
                                            </td>
                                            <td className="px-6 py-4 text-right">
                                                <button onClick={() => handleOpenModal(service)} className="text-blue-600 hover:underline mr-3 font-medium">Sửa</button>
                                                <button onClick={() => handleDelete(service.id)} className="text-red-500 hover:underline font-medium">Xóa</button>
                                            </td>
                                        </tr>
                                    );
                                })
                            )}
                        </tbody>
                    </table>
                </div>
            </div>

            {/* Modal Form */}
            {isModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4 animate-fade-in">
                    <div className="w-full max-w-2xl bg-white rounded-xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                            <h3 className="text-lg font-bold text-gray-800">{currentService ? 'Cập nhật Dịch vụ' : 'Thêm Dịch vụ mới'}</h3>
                            <button onClick={handleCloseModal} className="text-gray-400 hover:text-gray-600 font-bold text-xl">&times;</button>
                        </div>

                        <div className="p-6 overflow-y-auto">
                            <form id="serviceForm" onSubmit={handleSubmit} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="col-span-2">
                                        <label className="label">Tên dịch vụ <span className="text-red-500">*</span></label>
                                        <input
                                            type="text"
                                            className="input-field"
                                            required
                                            value={formData.name}
                                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                            placeholder="Ví dụ: Dọn nhà theo giờ"
                                        />
                                    </div>

                                    <div>
                                        <label className="label">Danh mục <span className="text-red-500">*</span></label>
                                        <select
                                            className="input-field"
                                            required
                                            value={formData.categoryId}
                                            onChange={(e) => setFormData({ ...formData, categoryId: e.target.value })}
                                        >
                                            <option value="">-- Chọn danh mục --</option>
                                            {categories.map(cat => (
                                                <option key={cat.id} value={cat.id}>{cat.name}</option>
                                            ))}
                                        </select>
                                    </div>

                                    <div className="grid grid-cols-1 md:grid-cols-4 gap-4 col-span-2">
                                        <div>
                                            <label className="label">Giá sàn (VNĐ)</label>
                                            <input
                                                type="number"
                                                className="input-field"
                                                required
                                                value={formData.minPrice}
                                                onChange={(e) => setFormData({ ...formData, minPrice: e.target.value })}
                                                placeholder="Sàn"
                                            />
                                        </div>
                                        <div>
                                            <label className="label">Giá gợi ý (VNĐ)</label>
                                            <input
                                                type="number"
                                                className="input-field"
                                                required
                                                value={formData.suggestedPrice}
                                                onChange={(e) => setFormData({ ...formData, suggestedPrice: e.target.value })}
                                                placeholder="Gợi ý"
                                            />
                                        </div>
                                        <div>
                                            <label className="label">Giá trần (VNĐ)</label>
                                            <input
                                                type="number"
                                                className="input-field"
                                                required
                                                value={formData.maxPrice}
                                                onChange={(e) => setFormData({ ...formData, maxPrice: e.target.value })}
                                                placeholder="Trần"
                                            />
                                        </div>
                                        <div>
                                            <label className="label">Đơn vị tính</label>
                                            <select
                                                className="input-field"
                                                value={formData.priceUnit}
                                                onChange={(e) => setFormData({ ...formData, priceUnit: e.target.value })}
                                            >
                                                <option value="lần">Lần</option>
                                                <option value="giờ">Giờ</option>
                                                <option value="m²">m²</option>
                                                <option value="cái">Cái</option>
                                                <option value="bộ">Bộ</option>
                                                <option value="km">Km</option>
                                                <option value="kg">Kg</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div className="col-span-2">
                                        <IconPicker
                                            selectedIcon={formData.iconName}
                                            onSelect={(name) => setFormData({ ...formData, iconName: name })}
                                        />
                                    </div>

                                    <div>
                                        <label className="label">URL Ảnh bìa</label>
                                        <input
                                            type="text"
                                            className="input-field"
                                            value={formData.imageUrl}
                                            onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
                                            placeholder="https://..."
                                        />
                                    </div>

                                    <div className="col-span-2">
                                        <label className="label">Mô tả ngắn</label>
                                        <textarea
                                            rows="3"
                                            className="input-field w-full"
                                            value={formData.description}
                                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                            placeholder="Mô tả ngắn gọn về dịch vụ..."
                                        ></textarea>
                                    </div>

                                    <div className="col-span-2">
                                        <label className="flex items-center gap-2 cursor-pointer">
                                            <input
                                                type="checkbox"
                                                className="w-5 h-5 text-blue-600 rounded"
                                                checked={formData.isActive}
                                                onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                                            />
                                            <span className="text-gray-700 font-medium">Kích hoạt hiển thị</span>
                                        </label>
                                    </div>
                                </div>
                            </form>
                        </div>

                        <div className="px-6 py-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-3">
                            <button type="button" onClick={handleCloseModal} className="px-4 py-2 text-gray-600 hover:bg-gray-200 rounded-lg font-medium">Hủy bỏ</button>
                            <button type="submit" form="serviceForm" className="px-6 py-2 bg-blue-600 text-white hover:bg-blue-700 rounded-lg font-medium shadow-sm">
                                {currentService ? 'Lưu cập nhật' : 'Tạo dịch vụ'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default ServiceManager;

