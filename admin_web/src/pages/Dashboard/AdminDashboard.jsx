import React from 'react';
import MainLayout from '../../layouts/MainLayout';

const AdminDashboard = () => {
    return (
        <MainLayout title="Dashboard">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                {/* Stats Cards Placeholder */}
                {['Tổng thợ', 'Khách hàng', 'Dịch vụ', 'Doanh thu'].map((item) => (
                    <div key={item} className="bg-white p-6 rounded-xl border border-gray-100 shadow-sm">
                        <h3 className="text-gray-500 text-sm font-medium">{item}</h3>
                        <p className="text-2xl font-bold text-gray-800 mt-2">1,234</p>
                    </div>
                ))}
            </div>

            <div className="bg-white rounded-xl border border-gray-100 shadow-sm p-6">
                <h2 className="text-lg font-bold text-gray-800 mb-4">Hoạt động gần đây</h2>
                <div className="text-gray-500 text-sm text-center py-8">
                    Chưa có dữ liệu
                </div>
            </div>
        </MainLayout>
    );
};

export default AdminDashboard;
