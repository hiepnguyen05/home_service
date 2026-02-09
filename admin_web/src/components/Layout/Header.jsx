import React from 'react';

const Header = ({ title }) => {
    return (
        <header className="h-16 flex items-center justify-between px-8 bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-slate-200 dark:border-slate-800 sticky top-0 z-10">
            <div className="flex items-center gap-2 text-sm">
                <span className="text-slate-400">Admin</span>
                <span className="text-slate-300 dark:text-slate-700">/</span>
                <span className="font-medium">{title}</span>
            </div>
            <div className="flex items-center gap-4">
                <button className="size-9 flex items-center justify-center rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-500">
                    <span className="material-symbols-outlined">notifications</span>
                </button>
                <div className="h-6 w-px bg-slate-200 dark:border-slate-800"></div>
                <button className="px-3 py-1.5 text-xs font-semibold rounded-lg bg-green-50 dark:bg-green-900/20 text-green-600 dark:text-green-400 flex items-center gap-2">
                    Hệ thống: Hoạt động tốt
                    <div className="size-2 rounded-full bg-green-500"></div>
                </button>
            </div>
        </header>
    );
};

export default Header;
