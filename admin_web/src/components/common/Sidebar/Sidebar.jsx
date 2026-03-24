import React from 'react';
import { NavLink } from 'react-router-dom';
import './Sidebar.css';

const Sidebar = () => {
    const menuItems = [
        {
            path: '/dashboard',
            label: 'Dashboard',
            icon: '📊'
        },
        {
            path: '/users',
            label: 'Quản lý người dùng',
            icon: '👥'
        },
        {
            path: '/workers',
            label: 'Quản lý thợ',
            icon: '🔧'
        },
        {
            path: '/orders',
            label: 'Quản lý đơn hàng',
            icon: '📅'
        },
        {
            path: '/services',
            label: 'Dịch vụ',
            icon: '⚙️'
        },
        {
            path: '/payments',
            label: 'Thanh toán',
            icon: '💳'
        },
        {
            path: '/reports',
            label: 'Báo cáo',
            icon: '📈'
        }
    ];

    return (
        <aside className="sidebar">
            <div className="sidebar-header">
                <h2 className="sidebar-title">HomeService Admin</h2>
            </div>
            <nav className="sidebar-nav">
                <ul className="nav-list">
                    {menuItems.map((item) => (
                        <li key={item.path} className="nav-item">
                            <NavLink
                                to={item.path}
                                className={({ isActive }) =>
                                    `nav-link ${isActive ? 'active' : ''}`
                                }
                            >
                                <span className="nav-icon">{item.icon}</span>
                                <span className="nav-label">{item.label}</span>
                            </NavLink>
                        </li>
                    ))}
                </ul>
            </nav>
        </aside>
    );
};

export default Sidebar;
