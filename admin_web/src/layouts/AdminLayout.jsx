import React from 'react';
import Sidebar from '../components/Layout/Sidebar';
import Header from '../components/Layout/Header';

const AdminLayout = ({ children, title = "Dashboard" }) => {
    return (
        <div className="flex min-h-screen">
            <Sidebar />
            <main className="flex-1 flex flex-col bg-background-light dark:bg-background-dark min-w-0">
                <Header title={title} />
                {children}
            </main>
        </div>
    );
};

export default AdminLayout;
