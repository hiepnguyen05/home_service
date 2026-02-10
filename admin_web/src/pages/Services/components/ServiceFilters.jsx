import React from 'react';
import { FaSearch, FaFilter } from 'react-icons/fa';

const ServiceFilters = ({ searchTerm, onSearchChange, selectedCategory, onCategoryChange, categories }) => {
    return (
        <div className="p-4 border-b border-gray-100 flex flex-col md:flex-row gap-4 justify-between items-center bg-white rounded-t-xl">
            {/* Search */}
            <div className="relative flex-1 w-full md:max-w-md group">
                <div className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400 group-focus-within:text-[#4CAE4F] transition-colors">
                    <FaSearch />
                </div>
                <input
                    type="text"
                    placeholder="Tìm kiếm dịch vụ theo tên..."
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/30 focus:border-[#4CAE4F] outline-none transition-all"
                    value={searchTerm}
                    onChange={(e) => onSearchChange(e.target.value)}
                />
            </div>

            {/* Category Filter */}
            <div className="relative w-full md:w-64">
                <div className="absolute inset-y-0 left-0 flex items-center pl-3 text-gray-400">
                    <FaFilter />
                </div>
                <select
                    className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-xl focus:ring-2 focus:ring-[#4CAE4F]/30 focus:border-[#4CAE4F] outline-none transition-all bg-white appearance-none cursor-pointer hover:border-[#4CAE4F]/50"
                    value={selectedCategory}
                    onChange={(e) => onCategoryChange(e.target.value)}
                >
                    <option value="">Tất cả danh mục</option>
                    {categories.map(cat => (
                        <option key={cat.id} value={cat.id}>{cat.name}</option>
                    ))}
                </select>
                <div className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-gray-400">
                    <svg className="w-4 h-4 fill-current" viewBox="0 0 20 20">
                        <path d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clipRule="evenodd" fillRule="evenodd"></path>
                    </svg>
                </div>
            </div>
        </div>
    );
};

export default ServiceFilters;
