import React from 'react';

/**
 * Component hiển thị các Tab trạng thái của nhà cung cấp.
 * 
 * @component
 * @param {Object} props
 * @param {string} props.activeTab - Trạng thái tab hiện tại.
 * @param {Function} props.setActiveTab - Hàm thay đổi tab.
 * @param {Function} props.setCurrentPage - Hàm reset phân trang.
 * @param {number} props.pendingCount - Số lượng đơn chờ duyệt.
 */
const ProviderTabs = ({ activeTab, setActiveTab, setCurrentPage, pendingCount }) => {

    /**
     * Xử lý sự kiện khi người dùng click vào tab.
     * Cập nhật tab hiện tại và reset trang về 1.
     * 
     * @param {string} tab - Tên tab cần chuyển đến.
     */
    const handleTabChange = (tab) => {
        setActiveTab(tab);
        setCurrentPage(1);
    };

    return (
        <div className="flex gap-2 p-1 bg-slate-100 dark:bg-slate-800 rounded-xl w-fit">
            <button
                onClick={() => handleTabChange('pending')}
                className={`${activeTab === 'pending'
                    ? 'bg-white dark:bg-slate-700 text-green-600 shadow-sm'
                    : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200'
                    } px-4 py-2 rounded-lg text-sm font-semibold transition-all flex items-center gap-2 relative`}
            >
                <span className="material-symbols-outlined text-[18px]">hourglass_top</span>
                Chờ duyệt
                {pendingCount > 0 && (
                    <span className="ml-1 bg-red-500 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full min-w-[1.25rem] text-center">
                        {pendingCount}
                    </span>
                )}
            </button>
            <button
                onClick={() => handleTabChange('approved')}
                className={`${activeTab === 'approved'
                    ? 'bg-white dark:bg-slate-700 text-green-600 shadow-sm'
                    : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200'
                    } px-4 py-2 rounded-lg text-sm font-semibold transition-all flex items-center gap-2`}
            >
                <span className="material-symbols-outlined text-[18px]">check_circle</span>
                Đã duyệt
            </button>
            <button
                onClick={() => handleTabChange('rejected')}
                className={`${activeTab === 'rejected'
                    ? 'bg-white dark:bg-slate-700 text-red-600 shadow-sm'
                    : 'text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200'
                    } px-4 py-2 rounded-lg text-sm font-semibold transition-all flex items-center gap-2`}
            >
                <span className="material-symbols-outlined text-[18px]">cancel</span>
                Từ chối
            </button>
        </div>
    );
};

export default ProviderTabs;
