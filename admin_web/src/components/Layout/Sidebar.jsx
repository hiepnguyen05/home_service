import React from 'react';
import { NavLink } from 'react-router-dom';

const Sidebar = () => {
    const mainNavItems = [
        { path: '/dashboard', label: 'Bảng điều khiển', icon: 'dashboard' },
        { path: '/customers', label: 'Khách hàng', icon: 'group' },
        { path: '/providers', label: 'Quản lý Thợ', icon: 'engineering' },
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

    return (
        <aside className="w-64 border-r border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 flex flex-col shrink-0">
            <div className="p-6 flex items-center gap-3">
                <div className="size-10 rounded-lg bg-[#4CAE4F] flex items-center justify-center text-white shadow-lg shadow-green-200/50">
                    <span className="material-symbols-outlined">home_repair_service</span>
                </div>
                <div>
                    <h1 className="text-sm font-bold uppercase tracking-wider">HomeService</h1>
                    <p className="text-xs text-slate-500">Trang Quản Trị</p>
                </div>
            </div>

            <nav className="flex-1 px-4 py-4 space-y-1">
                {mainNavItems.map((item) => (
                    <NavItem key={item.path} item={item} />
                ))}
            </nav>

            <div className="p-4 mt-auto border-t border-slate-200 dark:border-slate-800">
                <NavLink
                    to="/settings"
                    className="flex items-center gap-3 px-3 py-2 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors"
                >
                    <span className="material-symbols-outlined">settings</span>
                    <span className="text-sm font-medium">Cài đặt</span>
                </NavLink>
                <div className="mt-4 flex items-center gap-3 px-3">
                    <div className="size-8 rounded-full bg-slate-300 dark:bg-slate-700 bg-cover bg-center" style={{ backgroundImage: 'url("https://lh3.googleusercontent.com/aida-public/AB6AXuDt9UUnopQnjIIUe5sXBv6Jxip5Pp3ri-CNPN870Lcv2rMIh7Lx5pPYBipdtLhZE-i0UPpfqyT18L4V8zxSFT-PkHHXA-N5JL_CMMbzmkq5tmQ2pL1GWsHkzma7m0wUr1KALiybcjFUQd5dN4ej8mP4YTsAARUWlx7f0bq3B1mwYIi-K5ORycRgLCtIGPmlyuPCOI4GkFTcHyjm-Uihw6bhBiozORuhWDaucZDrULxy3XndmrE7mH-MICbFfX24M7asUEGGxrrMJmIe")' }}></div>
                    <div className="overflow-hidden">
                        <p className="text-xs font-semibold truncate">Alex Rivera</p>
                        <p className="text-[10px] text-slate-500 uppercase">Quản trị viên</p>
                    </div>
                </div>
            </div>
        </aside>
    );
};

export default Sidebar;
