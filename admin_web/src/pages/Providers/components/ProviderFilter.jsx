import React from 'react';

/**
 * Component bộ lọc và tìm kiếm nhà cung cấp.
 * Hiện tại chỉ hỗ trợ tìm kiếm theo từ khóa.
 * 
 * @component
 * @param {Object} props
 * @param {string} props.searchTerm - Từ khóa tìm kiếm hiện tại.
 * @param {Function} props.setSearchTerm - Hàm cập nhật từ khóa tìm kiếm.
 */
const ProviderFilter = ({
    searchTerm,
    setSearchTerm,
    categories = [],
    services = [],
    selectedCategory,
    setSelectedCategory,
    selectedService,
    setSelectedService
}) => {
    // Filter services based on selected category
    const filteredServices = selectedCategory
        ? services.filter(s => (s.category || s.categoryId) === selectedCategory)
        : services;

    return (
        <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 flex flex-wrap gap-4 items-center shadow-sm">
            {/* Search Input */}
            <div className="relative flex-1 min-w-[300px]">
                <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">search</span>
                <input
                    className="w-full pl-10 pr-4 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm placeholder:text-slate-500 transition-all"
                    placeholder="Tìm kiếm thợ..."
                    type="text"
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                />
            </div>

            {/* Category Filter */}
            <div className="min-w-[200px]">
                <select
                    className="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm outline-none transition-all cursor-pointer appearance-none"
                    value={selectedCategory}
                    onChange={(e) => {
                        setSelectedCategory(e.target.value);
                        setSelectedService(''); // Reset service when category changes
                    }}
                >
                    <option value="">Tất cả danh mục</option>
                    {categories.map(cat => (
                        <option key={cat.id} value={cat.id}>{cat.name}</option>
                    ))}
                </select>
            </div>

            {/* Service Filter */}
            <div className="min-w-[200px]">
                <select
                    className="w-full px-4 py-2.5 bg-slate-50 dark:bg-slate-800 border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm outline-none transition-all cursor-pointer appearance-none"
                    value={selectedService}
                    onChange={(e) => setSelectedService(e.target.value)}
                    disabled={!selectedCategory && services.length > 50}
                >
                    <option value="">
                        {selectedCategory ? `Dịch vụ thuộc danh mục này` : `Tất cả dịch vụ`}
                    </option>
                    {filteredServices.map(service => (
                        <option key={service.id} value={service.id}>{service.name}</option>
                    ))}
                </select>
            </div>
        </div>
    );
};

export default ProviderFilter;
