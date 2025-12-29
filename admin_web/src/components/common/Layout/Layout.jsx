import React from 'react';
import Header from '../Header/Header';
import Sidebar from '../Sidebar/Sidebar';
import './Layout.css';

const Layout = ({ children, title, user }) => {
    return (
        <div className="layout">
            <Sidebar />
            <div className="main-content">
                <Header title={title} user={user} />
                <main className="content">
                    {children}
                </main>
            </div>
        </div>
    );
};

export default Layout;