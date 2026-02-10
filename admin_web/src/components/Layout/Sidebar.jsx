import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const Sidebar = () => {
    // ... nav items ...
    const mainNavItems = [
        { path: '/dashboard', label: 'Bảng điều khiển', icon: 'dashboard' },
        { path: '/customers', label: 'Khách hàng', icon: 'group' },
        { path: '/providers', label: 'Quản lý Thợ', icon: 'engineering' },
        { path: '/categories', label: 'Danh mục', icon: 'category' },
        { path: '/services', label: 'Dịch vụ', icon: 'construction' },
        { path: '/orders', label: 'Đơn hàng', icon: 'event_available' },
        { path: '/reports', label: 'Báo cáo', icon: 'analytics' },
    ];

    const NavItem = ({ item }) => (
        <NavLink
            to={item.path}
            className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2 rounded-lg transition-colors ${isActive
                    ? 'bg-green-50 dark:bg-green-900/20 text-[#4CAE4F]'
                    : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
                }`
            }
        >
            {({ isActive }) => (
                <>
                    <span className="material-symbols-outlined" style={isActive ? { fontVariationSettings: "'FILL' 1" } : {}}>
                        {item.icon}
                    </span>
                    <span className="text-sm font-medium">{item.label}</span>
                </>
            )}
        </NavLink>
    );

    const { currentUser, userData, logout } = useAuth();
    const navigate = useNavigate();

    const handleLogout = async () => {
        try {
            await logout();
            navigate('/admin-login');
        } catch (error) {
            console.error('Logout failed:', error);
        }
    };

    return (
        <aside className="w-full h-full flex flex-col bg-white dark:bg-slate-900">
            <div className="p-6 flex items-center gap-3 flex-shrink-0">
                <div className="size-10 rounded-lg bg-[#4CAE4F] flex items-center justify-center text-white shadow-lg shadow-green-200/50">
                    <span className="material-symbols-outlined">home_repair_service</span>
                </div>
                <div>
                    <h1 className="text-sm font-bold uppercase tracking-wider">HomeService</h1>
                    <p className="text-xs text-slate-500">Trang Quản Trị</p>
                </div>
            </div>

            <nav className="flex-1 px-4 py-4 space-y-1 overflow-y-auto custom-scrollbar">
                {mainNavItems.map((item) => (
                    <NavItem key={item.path} item={item} />
                ))}
            </nav>

            <div className="p-4 mt-auto border-t border-slate-200 dark:border-slate-800 flex-shrink-0 bg-white dark:bg-slate-900 z-10 space-y-2">
                <NavLink
                    to="/settings"
                    className="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors"
                >
                    <span className="material-symbols-outlined">settings</span>
                    <span className="text-sm font-medium">Cài đặt</span>
                </NavLink>

                <div className="flex items-center gap-3 px-3 py-2">
                    {userData?.photoURL || currentUser?.photoURL ? (
                        <div className="size-8 rounded-full bg-slate-300 dark:bg-slate-700 bg-cover bg-center" style={{ backgroundImage: `url("${userData?.photoURL || currentUser?.photoURL}")` }}></div>
                    ) : (
                        <div className="size-8 rounded-full bg-blue-500 flex items-center justify-center text-white font-bold text-xs">
                            {(userData?.name?.[0] || currentUser?.displayName?.[0] || currentUser?.email?.[0] || 'A').toUpperCase()}
                        </div>
                    )}
                    <div className="overflow-hidden">
                        <p className="text-xs font-semibold truncate">
                            {userData?.name || currentUser?.displayName || currentUser?.email || 'Admin User'}
                        </p>
                        <p className="text-[10px] text-slate-500 uppercase">
                            {userData?.role || 'Quản trị viên'}
                        </p>
                    </div>
                </div>

                <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-3 px-3 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors text-left border-t border-slate-100 pt-3"
                >
                    <span className="material-symbols-outlined">logout</span>
                    <span className="text-sm font-medium">Đăng xuất</span>
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
