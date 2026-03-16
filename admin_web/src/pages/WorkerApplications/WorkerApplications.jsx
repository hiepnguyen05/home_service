import React, { useState, useEffect } from 'react';
import { collection, query, where, getDocs, doc, updateDoc, getDoc, setDoc } from 'firebase/firestore';
import { firestore as db } from '../../firebase/config';
import { FaCheck, FaTimes, FaEye } from 'react-icons/fa';
import { approveProvider, rejectProvider } from '../../services/providerService';

const WorkerApplications = () => {
    const [applications, setApplications] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selectedApp, setSelectedApp] = useState(null); // For modal details

    useEffect(() => {
        fetchApplications();
    }, []);

    const fetchApplications = async () => {
        try {
            const q = query(
                collection(db, 'partner_requests'),
                where('status', '==', 'pending')
            );
            const querySnapshot = await getDocs(q);
            const apps = [];
            querySnapshot.forEach((doc) => {
                apps.push({ id: doc.id, ...doc.data() });
            });
            setApplications(apps);
        } catch (error) {
            console.error("Error fetching applications: ", error);
        } finally {
            setLoading(false);
        }
    };

    const handleApprove = async (userId, appId) => {
        if (!window.confirm("Bạn có chắc chắn muốn duyệt đơn này?")) return;
        try {
            setLoading(true);
            await approveProvider(userId, appId);
            await fetchApplications();
            setSelectedApp(null);
        } catch (error) {
            console.error("Error approving application: ", error);
            alert("Có lỗi xảy ra khi duyệt: " + error.message);
        } finally {
            setLoading(false);
        }
    };

    const handleReject = async (userId, appId) => {
        const reason = prompt("Nhập lý do từ chối:");
        if (reason === null) return; // Cancelled

        try {
            setLoading(true);
            await rejectProvider(userId, appId, reason);
            await fetchApplications();
            setSelectedApp(null);
        } catch (error) {
            console.error("Error rejecting application: ", error);
            alert("Có lỗi xảy ra khi từ chối: " + error.message);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return <div className="p-8 text-center">Đang tải dữ liệu...</div>;
    }

    return (
        <div className="p-6">
            <h1 className="text-2xl font-bold mb-6 text-gray-800">Duyệt hồ sơ & Yêu cầu chỉnh sửa</h1>

            {applications.length === 0 ? (
                <div className="bg-white rounded-lg shadow p-6 text-center text-gray-500">
                    Hiện không có yêu cầu nào đang chờ duyệt.
                </div>
            ) : (
                <div className="overflow-x-auto bg-white rounded-lg shadow">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Họ tên</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Số điện thoại</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Loại yêu cầu</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ngày gửi</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Hành động</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {applications.map((app) => (
                                <tr key={app.id} className="hover:bg-gray-50">
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="font-medium text-gray-900">{app.fullName}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-gray-500">
                                        {app.phoneNumber}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                                            app.requestType === 'update' 
                                            ? 'bg-blue-100 text-blue-800' 
                                            : 'bg-green-100 text-green-800'
                                        }`}>
                                            {app.requestType === 'update' ? 'Cập nhật hồ sơ' : 'Đăng ký mới'}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-gray-500">
                                        {app.createdAt?.seconds ? new Date(app.createdAt.seconds * 1000).toLocaleDateString('vi-VN') : 'Unknown'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <button
                                            onClick={() => setSelectedApp(app)}
                                            className="text-blue-600 hover:text-blue-900 mx-2"
                                            title="Xem chi tiết"
                                        >
                                            <FaEye size={18} />
                                        </button>
                                        <button
                                            onClick={() => handleApprove(app.userId, app.id)}
                                            className="text-green-600 hover:text-green-900 mx-2"
                                            title="Duyệt"
                                        >
                                            <FaCheck size={18} />
                                        </button>
                                        <button
                                            onClick={() => handleReject(app.userId, app.id)}
                                            className="text-red-600 hover:text-red-900 mx-2"
                                            title="Từ chối"
                                        >
                                            <FaTimes size={18} />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}

            {/* Detail Modal */}
            {selectedApp && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
                        <div className="p-6 border-b border-gray-100 flex justify-between items-center">
                            <div className="flex items-center gap-3">
                                <h2 className="text-xl font-bold text-gray-800">Chi tiết hồ sơ: {selectedApp.fullName}</h2>
                                <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                                    selectedApp.requestType === 'update' 
                                    ? 'bg-blue-100 text-blue-800' 
                                    : 'bg-green-100 text-green-800'
                                }`}>
                                    {selectedApp.requestType === 'update' ? 'Cập nhật hồ sơ' : 'Đăng ký mới'}
                                </span>
                            </div>
                            <button onClick={() => setSelectedApp(null)} className="text-gray-400 hover:text-gray-600">
                                <FaTimes size={24} />
                            </button>
                        </div>

                        <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <h3 className="font-semibold text-gray-700 mb-3">Thông tin {selectedApp.requestType === 'update' ? 'thợ' : 'cá nhân'}</h3>
                                <div className="space-y-2 text-sm">
                                    <p><span className="text-gray-500">ID người dùng:</span> {selectedApp.userId}</p>
                                    <p><span className="text-gray-500">SĐT:</span> {selectedApp.phoneNumber}</p>
                                    <p><span className="text-gray-500">Ngày gửi yêu cầu:</span> {selectedApp.createdAt?.seconds ? new Date(selectedApp.createdAt.seconds * 1000).toLocaleString('vi-VN') : ''}</p>
                                </div>

                                {selectedApp.requestType !== 'update' && (
                                    <>
                                        <h3 className="font-semibold text-gray-700 mt-6 mb-3">CMND/CCCD</h3>
                                        <div className="grid grid-cols-2 gap-4">
                                            <div>
                                                <p className="text-xs text-gray-500 mb-1">Mặt trước</p>
                                                {selectedApp.idFrontUrl ? (
                                                    <img src={selectedApp.idFrontUrl} alt="ID Front" className="w-full h-32 object-cover rounded border" />
                                                ) : (
                                                    <div className="w-full h-32 bg-gray-100 rounded border flex items-center justify-center text-gray-400">Không có ảnh</div>
                                                )}
                                            </div>
                                            <div>
                                                <p className="text-xs text-gray-500 mb-1">Mặt sau</p>
                                                {selectedApp.idBackUrl ? (
                                                    <img src={selectedApp.idBackUrl} alt="ID Back" className="w-full h-32 object-cover rounded border" />
                                                ) : (
                                                    <div className="w-full h-32 bg-gray-100 rounded border flex items-center justify-center text-gray-400">Không có ảnh</div>
                                                )}
                                            </div>
                                        </div>
                                    </>
                                )}
                            </div>

                            <div>
                                <h3 className="font-semibold text-gray-700 mb-3">{selectedApp.requestType === 'update' ? 'Chi tiết Thay đổi Kỹ năng & Giá' : 'Dịch vụ đăng ký'}</h3>
                                {selectedApp.services && selectedApp.services.length > 0 ? (
                                    <div className="border rounded-lg overflow-hidden">
                                        <table className="min-w-full divide-y divide-gray-200">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500">Dịch vụ</th>
                                                    {selectedApp.requestType === 'update' && (
                                                        <th className="px-4 py-2 text-center text-xs font-medium text-gray-500">Loại</th>
                                                    )}
                                                    <th className="px-4 py-2 text-right text-xs font-medium text-gray-500">Giá đề xuất</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-200">
                                                {selectedApp.services.map((svc, idx) => (
                                                    <tr key={idx} className={
                                                        svc.changeType === 'deleted' ? 'bg-red-50' : 
                                                        svc.changeType === 'added' ? 'bg-green-50' : ''
                                                    }>
                                                        <td className="px-4 py-2 text-sm text-gray-900">
                                                            <div>{svc.serviceName || svc.serviceId}</div>
                                                            {svc.changeType === 'deleted' && <div className="text-[10px] text-red-500 font-bold uppercase">Ngừng cung cấp</div>}
                                                        </td>
                                                        {selectedApp.requestType === 'update' && (
                                                            <td className="px-4 py-2 text-center">
                                                                <span className={`inline-block px-1.5 py-0.5 rounded text-[10px] font-bold uppercase ${
                                                                    svc.changeType === 'added' ? 'bg-green-100 text-green-700' :
                                                                    svc.changeType === 'updated' ? 'bg-amber-100 text-amber-700' :
                                                                    svc.changeType === 'deleted' ? 'bg-red-100 text-red-700' :
                                                                    'bg-slate-100 text-slate-700'
                                                                }`}>
                                                                    {svc.changeType === 'added' ? 'Mới' :
                                                                     svc.changeType === 'updated' ? 'Sửa giá' :
                                                                     svc.changeType === 'deleted' ? 'Xóa' : '---'
                                                                    }
                                                                </span>
                                                            </td>
                                                        )}
                                                        <td className="px-4 py-2 text-sm text-right text-gray-900">
                                                            {svc.changeType === 'updated' && svc.oldPrice ? (
                                                                <div className="flex flex-col items-end">
                                                                    <span className="text-[10px] text-gray-400 line-through">{svc.oldPrice} đ</span>
                                                                    <span className="font-bold text-green-600">{svc.price} đ</span>
                                                                </div>
                                                            ) : (
                                                                <span className={svc.changeType === 'deleted' ? 'text-gray-400 line-through' : 'font-bold'}>
                                                                    {svc.price} đ
                                                                </span>
                                                            )}
                                                        </td>
                                                    </tr>
                                                ))}
                                            </tbody>
                                        </table>
                                    </div>
                                ) : (
                                    <p className="text-sm text-gray-500">Không có dịch vụ nào.</p>
                                )}

                                {selectedApp.bio && (
                                    <div className="mt-6">
                                        <h3 className="font-semibold text-gray-700 mb-3">Giới thiệu</h3>
                                        <div className="p-3 bg-gray-50 rounded border text-sm text-gray-600">
                                            {selectedApp.bio}
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>

                        <div className="p-6 border-t border-gray-100 flex justify-end gap-3 bg-gray-50 rounded-b-lg">
                            <button
                                onClick={() => handleReject(selectedApp.userId, selectedApp.id)}
                                className="px-4 py-2 bg-white border border-red-500 text-red-600 rounded-lg hover:bg-red-50 font-medium"
                            >
                                Từ chối
                            </button>
                            <button
                                onClick={() => handleApprove(selectedApp.userId, selectedApp.id)}
                                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-medium shadow-sm"
                            >
                                {selectedApp.requestType === 'update' ? 'Duyệt thay đổi' : 'Duyệt hồ sơ'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default WorkerApplications;
