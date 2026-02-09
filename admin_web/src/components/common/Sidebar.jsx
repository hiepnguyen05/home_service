import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import {
    MdDashboard,
    MdPeople,
    MdEngineering,
    MdCategory,
    MdMiscellaneousServices,
    MdSettings,
    MdLogout
} from 'react-icons/md';
import { useFirebase } from '../../context/FirebaseContext';
import { signOut } from 'firebase/auth';

const Sidebar = () => {
    const { auth } = useFirebase();
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            await signOut(auth);
            navigate('/admin-login');
        } catch (error) {
            console.error('Logout error:', error);
        }
    };

    const navItems = [
        { path: '/dashboard', label: 'Dashboard', icon: MdDashboard },
        { path: '/workers', label: 'Quản lý Thợ', icon: MdEngineering },
        { path: '/services', label: 'Dịch vụ', icon: MdMiscellaneousServices },
        { path: '/categories', label: 'Danh mục', icon: MdCategory },
        { path: '/customers', label: 'Khách hàng', icon: MdPeople },
        // { path: '/settings', label: 'Cài đặt', icon: MdSettings },
    ];

    return (
        <aside className="hidden md:flex flex-col w-64 h-screen bg-white border-r border-gray-200 sticky top-0 left-0 z-30">
            {/* Logo Section */}
            <div className="flex items-center justify-center h-16 border-b border-gray-100 shrink-0">
                <h1 className="text-xl font-bold text-green-600 tracking-wide">HomeService <span className="text-gray-400 text-xs">Admin</span></h1>
            </div>

            {/* Navigation Links */}
            <nav className="flex-1 overflow-y-auto py-6 px-3 space-y-1">
                {navItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        className={({ isActive }) =>
                            `flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium transition-all duration-200 group ${isActive
                                ? 'bg-green-50 text-green-700 shadow-sm'
                                : 'text-gray-500 hover:bg-gray-50 hover:text-gray-900'
                            }`
                        }
                    >
                        {({ isActive }) => (
                            <>
                                <item.icon className={`text-xl transition-colors ${isActive ? 'text-green-600' : 'text-gray-400 group-hover:text-gray-600'}`} />
                                <span>{item.label}</span>
                            </>
                        )}
                    </NavLink>
                ))}
            </nav>

            {/* User / Logout Section */}
            <div className="p-4 border-t border-gray-100 shrink-0 bg-gray-50/50">
                <button
                    onClick={handleLogout}
                    className="flex items-center gap-3 w-full px-4 py-2 text-sm font-medium text-gray-600 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                >
                    <MdLogout className="text-xl" />
                    <span>Đăng xuất</span>
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
