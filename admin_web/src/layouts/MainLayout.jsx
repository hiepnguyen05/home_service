import React from 'react';
import Sidebar from '../components/common/Sidebar';
import Header from '../components/common/Header';

const MainLayout = ({ children, title }) => {
    return (
        <div className="flex h-screen w-full bg-gray-50/50 font-sans text-gray-800 overflow-hidden">
            {/* Sidebar (Fixed Left) */}
            <Sidebar />

            {/* Content Wrapper (Right Side) */}
            <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
                {/* Header (Fixed Top) */}
                <Header title={title} />

                {/* Scrollable Content Body */}
                <main className="flex-1 overflow-y-auto p-6 md:p-8 relative scroll-smooth">
                    <div className="mx-auto max-w-7xl animate-fadeIn">
                        {children}
                    </div>
                </main>
            </div>
        </div>
    );
};

export default MainLayout;
