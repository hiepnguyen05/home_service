import React from 'react';

/**
 * Component lọc và tìm kiếm khách hàng.
 */
const CustomerFilter = ({ searchTerm, setSearchTerm }) => {
    return (
        <div className="bg-white dark:bg-slate-900 p-4 rounded-xl border border-slate-200 dark:border-slate-800 shadow-sm">
            <div className="flex flex-col md:flex-row gap-4 items-center">
                <div className="relative flex-1 group">
                    <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-green-500 transition-colors">
                        search
                    </span>
                    <input
                        type="text"
                        placeholder="Tìm kiếm theo tên, email hoặc số điện thoại..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="w-full pl-10 pr-4 py-2 bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg focus:ring-2 focus:ring-green-500 outline-none transition-all text-sm font-medium"
                    />
                </div>
                
                {/* Có thể thêm các bộ lọc khác ở đây trong tương lai */}
                <div className="flex items-center gap-2 text-xs font-bold text-slate-400 uppercase tracking-widest px-2">
                    <span className="material-symbols-outlined text-sm">filter_list</span>
                    Bộ lọc
                </div>
            </div>
        </div>
    );
};

export default CustomerFilter;
