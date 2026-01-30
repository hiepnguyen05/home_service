import React from 'react';
import { NavLink } from 'react-router-dom';
import { FaHome, FaList, FaServicestack, FaUserCheck } from 'react-icons/fa';

const Sidebar = () => {
    return (
        <aside className="w-64 bg-white border-r border-gray-200 h-screen fixed left-0 top-0 pt-16 z-10 flex flex-col">
            <div className="flex flex-col flex-1 overflow-y-auto px-4 py-4 gap-2">
                <NavLink
                    to="/admin-dashboard"
                    className={({ isActive }) =>
                        `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-blue-50 text-blue-600 font-medium' : 'text-gray-600 hover:bg-gray-50'
                        }`
                    }
                >
                    <FaHome size={20} />
                    <span>Dashboard</span>
                </NavLink>

                <NavLink
                    to="/categories"
                    className={({ isActive }) =>
                        `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-blue-50 text-blue-600 font-medium' : 'text-gray-600 hover:bg-gray-50'
                        }`
                    }
                >
                    <FaList size={20} />
                    <span>Quản lý Danh mục</span>
                </NavLink>

                <NavLink
                    to="/services"
                    className={({ isActive }) =>
                        `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-blue-50 text-blue-600 font-medium' : 'text-gray-600 hover:bg-gray-50'
                        }`
                    }
                >
                    <FaServicestack size={20} />
                    <span>Quản lý Dịch vụ</span>
                </NavLink>

                <NavLink
                    to="/worker-applications"
                    className={({ isActive }) =>
                        `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${isActive ? 'bg-blue-50 text-blue-600 font-medium' : 'text-gray-600 hover:bg-gray-50'
                        }`
                    }
                >
                    <FaUserCheck size={20} />
                    <span>Duyệt hồ sơ thợ</span>
                </NavLink>

                {/* Other items can be added here (Users, Bookings, etc.) */}
            </div>
            <div className="p-4 border-t border-gray-200">
                <div className="text-xs text-center text-gray-400">
                    HomeService Admin v1.0
                </div>
            </div>
        </aside>
    );
};

export default Sidebar;
