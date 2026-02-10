import React from 'react';
import Sidebar from '../components/Layout/Sidebar';
import Header from '../components/Layout/Header';

const AdminLayout = ({ children, title = "Dashboard" }) => {
    return (
        <div className="h-screen w-full flex bg-gray-50 dark:bg-slate-900 overflow-hidden">
            {/* Sidebar Wrapper - Fixed Width */}
            <div className="w-64 min-w-[16rem] h-full flex-shrink-0 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900">
                <Sidebar />
            </div>

            {/* Main Content Wrapper */}
            <div className="flex-1 flex flex-col h-full min-w-0 overflow-hidden relative">
                {/* Header */}
                <div className="flex-shrink-0 z-10">
                    <Header title={title} />
                </div>

                {/* Scrollable Page Content */}
                <main className="flex-1 overflow-y-auto p-6 scroll-smooth bg-gray-50 dark:bg-slate-900">
                    {children}
                </main>
            </div>
        </div>
    );
};

export default AdminLayout;
