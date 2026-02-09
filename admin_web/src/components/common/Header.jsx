import React from 'react';
// import { FaBell } from 'react-icons/fa'; // Uncomment when notification feature is ready

const Header = ({ title }) => {
    return (
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-8 sticky top-0 z-20 shrink-0">
            {/* Page Title */}
            <div>
                <h1 className="text-lg font-bold text-gray-800">{title || 'Admin Panel'}</h1>
            </div>

            {/* Right Side Actions (Notifications, Avatar) */}
            <div className="flex items-center gap-6">
                {/* Notification Bell (Placeholder) */}
                {/* 
                <button className="relative text-gray-400 hover:text-gray-600 transition-colors">
                    <FaBell className="text-lg" />
                    <span className="absolute -top-1 -right-1 flex h-2.5 w-2.5">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-red-500"></span>
                    </span>
                </button> 
                */}

                {/* User Profile */}
                <div className="flex items-center gap-3 pl-6 border-l border-gray-100">
                    <div className="text-right hidden sm:block">
                        <p className="text-sm font-medium text-gray-700">Admin User</p>
                        <p className="text-xs text-gray-400">Super Admin</p>
                    </div>
                    <div className="h-9 w-9 rounded-full bg-green-100 border border-green-200 flex items-center justify-center text-green-700 font-bold shadow-sm">
                        A
                    </div>
                </div>
            </div>
        </header>
    );
};

export default Header;
