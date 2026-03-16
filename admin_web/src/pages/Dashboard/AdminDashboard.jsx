import React from 'react';
import {
    Chart as ChartJS,
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Legend,
    Filler,
    ArcElement,
} from 'chart.js';
import { Line, Doughnut } from 'react-chartjs-2';

// Register ChartJS components
ChartJS.register(
    CategoryScale,
    LinearScale,
    PointElement,
    LineElement,
    Title,
    Tooltip,
    Legend,
    Filler,
    ArcElement
);

const AdminDashboard = () => {
    // Chart Data
    const revenueData = {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        datasets: [{
            label: 'Doanh thu',
            data: [12000, 19000, 15000, 25000, 22000, 30000, 28000, 32000, 29000, 35000, 40000, 38000],
            borderColor: '#4CAF50',
            backgroundColor: 'rgba(76, 175, 80, 0.1)',
            tension: 0.4,
            fill: true,
            pointRadius: 4,
            pointHoverRadius: 6,
        }]
    };

    const revenueOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { display: false },
            tooltip: {
                mode: 'index',
                intersect: false,
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    color: 'rgba(0, 0, 0, 0.05)',
                }
            },
            x: {
                grid: {
                    display: false,
                }
            }
        }
    };

    const servicesData = {
        labels: ['Dọn dẹp nhà', 'Sửa điện nước', 'Sửa điện lạnh', 'Làm vườn'],
        datasets: [{
            label: 'Top Dịch vụ',
            data: [300, 150, 100, 80],
            backgroundColor: ['#4CAF50', '#8BC34A', '#CDDC39', '#AED581'],
            hoverOffset: 4,
            borderWidth: 0,
        }]
    };

    const servicesOptions = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: { position: 'bottom' }
        },
        cutout: '70%',
    };

    return (
        <div className="space-y-6">
            {/* Header / Filter Section */}
            <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
                <div className="flex items-center gap-2">
                    <select className="px-4 py-2 rounded-lg border border-slate-200 dark:border-slate-700 focus:ring-2 focus:ring-[#4CAE4F] focus:border-[#4CAE4F] text-slate-700 dark:text-slate-200 bg-white dark:bg-slate-800 text-sm outline-none transition-all">
                        <option>30 ngày qua</option>
                        <option>90 ngày qua</option>
                        <option>6 tháng qua</option>
                        <option>1 năm qua</option>
                    </select>
                </div>
                <button className="w-full sm:w-auto flex items-center justify-center gap-2 px-4 py-2 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg text-sm font-medium text-slate-700 dark:text-slate-200 hover:bg-slate-50 dark:hover:bg-slate-700 transition-all shadow-sm">
                    <span className="material-symbols-outlined text-base">download</span>
                    Xuất báo cáo (CSV)
                </button>
            </div>

            {/* Charts Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2 bg-white dark:bg-slate-800 p-6 rounded-2xl border border-slate-100 dark:border-slate-700 shadow-sm">
                    <h3 className="text-lg font-semibold text-slate-800 dark:text-slate-100 mb-6 flex items-center gap-2">
                        <span className="material-symbols-outlined text-[#4CAE4F]">trending_up</span>
                        Doanh thu hàng tháng
                    </h3>
                    <div className="h-80">
                        <Line data={revenueData} options={revenueOptions} />
                    </div>
                </div>

                <div className="bg-white dark:bg-slate-800 p-6 rounded-2xl border border-slate-100 dark:border-slate-700 shadow-sm">
                    <h3 className="text-lg font-semibold text-slate-800 dark:text-slate-100 mb-6">Dịch vụ phổ biến</h3>
                    <div className="h-80">
                        <Doughnut data={servicesData} options={servicesOptions} />
                    </div>
                </div>

                {/* Technician Performance Table */}
                <div className="lg:col-span-3 bg-white dark:bg-slate-800 p-6 rounded-2xl border border-slate-100 dark:border-slate-700 shadow-sm overflow-hidden">
                    <h3 className="text-lg font-semibold text-slate-800 dark:text-slate-100 mb-6">Hiệu suất nhân viên thợ</h3>
                    <div className="overflow-x-auto -mx-6">
                        <table className="w-full text-left text-sm">
                            <thead className="text-xs text-slate-500 uppercase bg-slate-50 dark:bg-slate-900/50 border-y border-slate-100 dark:border-slate-700">
                                <tr>
                                    <th className="px-8 py-4 px-6 font-semibold">Nhân viên</th>
                                    <th className="px-6 py-4 font-semibold">Công việc hoàn thành</th>
                                    <th className="px-6 py-4 font-semibold">Đánh giá TB</th>
                                    <th className="px-8 py-4 font-semibold">Doanh thu mang lại</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
                                {[
                                    { name: 'Nguyễn Văn An', jobs: 45, rating: '4.9 ★', revenue: '15.230.000 đ' },
                                    { name: 'Trần Thị Bình', jobs: 38, rating: '4.8 ★', revenue: '12.810.000 đ' },
                                    { name: 'Lê Văn Cường', jobs: 35, rating: '4.7 ★', revenue: '10.400.000 đ' },
                                    { name: 'Phạm Minh Đức', jobs: 32, rating: '4.9 ★', revenue: '9.150.000 đ' },
                                ].map((tech, idx) => (
                                    <tr key={idx} className="hover:bg-slate-50/50 dark:hover:bg-slate-700/30 transition-colors">
                                        <th className="px-8 py-5 font-medium text-slate-800 dark:text-slate-200 whitespace-nowrap">{tech.name}</th>
                                        <td className="px-6 py-5 text-slate-600 dark:text-slate-400">{tech.jobs}</td>
                                        <td className="px-6 py-5">
                                            <span className="inline-flex items-center gap-1 px-2 py-1 rounded bg-amber-50 dark:bg-amber-900/20 text-amber-600 font-medium">
                                                {tech.rating}
                                            </span>
                                        </td>
                                        <td className="px-8 py-5 text-slate-800 dark:text-slate-200 font-semibold">{tech.revenue}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>

                {/* Customer Retention Cohort Table */}
                <div className="lg:col-span-3 bg-white dark:bg-slate-800 p-6 rounded-2xl border border-slate-100 dark:border-slate-700 shadow-sm overflow-hidden">
                    <h3 className="text-lg font-semibold text-slate-800 dark:text-slate-100 mb-6">Tỷ lệ giữ chân khách hàng (Cohort)</h3>
                    <div className="overflow-x-auto -mx-6">
                        <table className="w-full text-left text-sm border-collapse min-w-[800px]">
                            <thead className="text-xs text-slate-500 uppercase bg-slate-50 dark:bg-slate-900/50 border-y border-slate-100 dark:border-slate-700">
                                <tr>
                                    <th className="px-8 py-4 font-semibold">Tháng tham gia</th>
                                    <th className="px-6 py-4 font-semibold">Khách hàng</th>
                                    {Array.from({ length: 10 }).map((_, i) => (
                                        <th key={i} className="px-3 py-4 text-center font-semibold">Tháng {i + 1}</th>
                                    ))}
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-100 dark:divide-slate-700">
                                {[
                                    { cohort: 'Tháng 1/2024', users: '1,204', data: [100, 45, 38, 35, 32, 28, 25, 22, 18, 15] },
                                    { cohort: 'Tháng 2/2024', users: '1,452', data: [0, 100, 42, 36, 31, 29, 26, 21, 19] },
                                    { cohort: 'Tháng 3/2024', users: '1,388', data: [0, 0, 100, 48, 41, 35, 32, 27] },
                                ].map((row, idx) => (
                                    <tr key={idx}>
                                        <td className="px-8 py-5 font-medium text-slate-800 dark:text-slate-200">{row.cohort}</td>
                                        <td className="px-6 py-5 text-slate-600 dark:text-slate-400">{row.users}</td>
                                        {row.data.map((val, i) => (
                                            <td key={i} className="px-1 py-1">
                                                {val > 0 ? (
                                                    <div 
                                                        className="w-full h-10 flex items-center justify-center rounded text-xs font-medium"
                                                        style={{ 
                                                            backgroundColor: `rgba(76, 175, 80, ${val / 100})`,
                                                            color: val > 50 ? 'white' : 'inherit'
                                                        }}
                                                    >
                                                        {val}%
                                                    </div>
                                                ) : <div className="h-10"></div>}
                                            </td>
                                        ))}
                                        {Array.from({ length: 10 - row.data.length }).map((_, i) => (
                                            <td key={i + row.data.length} className="px-1 py-1">
                                                <div className="h-10 bg-slate-50/50 dark:bg-slate-900/20 rounded"></div>
                                            </td>
                                        ))}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AdminDashboard;
