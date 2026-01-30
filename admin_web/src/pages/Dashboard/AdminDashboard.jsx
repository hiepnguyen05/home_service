import React, { useState, useEffect } from 'react';
import { useFirebase } from '../../context/FirebaseContext';
import { useNavigate } from 'react-router-dom';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { collection, getDocs, query, orderBy, limit } from 'firebase/firestore';
import '../../styles/AdminDashboard.css';

const AdminDashboard = () => {
    const [user, setUser] = useState(null);
    const [isAdmin, setIsAdmin] = useState(false);
    const [loading, setLoading] = useState(true);
    const [dashboardData, setDashboardData] = useState({
        services: [],
        bookings: [],
        users: [],
        workers: []
    });

    const { auth, firestore } = useFirebase();
    const navigate = useNavigate();

    const checkAdminRole = async (userEmail) => {
        try {
            // Trước tiên kiểm tra danh sách email admin cố định
            const adminEmails = [
                'admin@homeservice.com',
                'admin@gmail.com',
                'nguyenngochiep@gmail.com',
                'quanly@homeservice.com'
            ];

            // Nếu email có trong danh sách admin, cho phép truy cập
            if (adminEmails.includes(userEmail)) {
                return true;
            }

            // Nếu không có trong danh sách, kiểm tra role từ Firestore
            const { doc, getDoc } = await import('firebase/firestore');
            const userDoc = await getDoc(doc(firestore, 'users', auth.currentUser.uid));

            if (userDoc.exists()) {
                const userData = userDoc.data();
                console.log('User data from Firestore:', userData);

                // Kiểm tra role trong document
                return userData.role === 'admin' || userData.role === 'administrator';
            }

            return false;
        } catch (error) {
            console.error('Lỗi khi kiểm tra quyền admin:', error);

            // Fallback: nếu có lỗi, kiểm tra email trong danh sách
            const adminEmails = [
                'admin@homeservice.com',
                'admin@gmail.com',
                'nguyenngochiep@gmail.com',
                'quanly@homeservice.com'
            ];

            return adminEmails.includes(userEmail);
        }
    };

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, async (user) => {
            if (user) {
                const isAdminUser = await checkAdminRole(user.email);

                if (isAdminUser) {
                    setUser(user);
                    setIsAdmin(true);
                    await loadDashboardData();
                } else {
                    setIsAdmin(false);
                    navigate('/admin-login');
                }
            } else {
                setIsAdmin(false);
                navigate('/admin-login');
            }
            setLoading(false);
        });

        return () => unsubscribe();
    }, [auth, navigate]);

    const loadDashboardData = async () => {
        try {
            // Tải dữ liệu services
            const servicesQuery = query(
                collection(firestore, 'services'),
                orderBy('createdAt', 'desc'),
                limit(10)
            );
            const servicesSnapshot = await getDocs(servicesQuery);
            const services = servicesSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            // Tải dữ liệu bookings
            const bookingsQuery = query(
                collection(firestore, 'bookings'),
                orderBy('createdAt', 'desc'),
                limit(10)
            );
            const bookingsSnapshot = await getDocs(bookingsQuery);
            const bookings = bookingsSnapshot.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            // Tải dữ liệu users (nếu có)
            try {
                const usersQuery = query(collection(firestore, 'users'), limit(5));
                const usersSnapshot = await getDocs(usersQuery);
                const users = usersSnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                }));

                setDashboardData(prev => ({ ...prev, users }));
            } catch (error) {
                console.log('Collection users không tồn tại:', error);
            }

            // Tải dữ liệu workers (nếu có)
            try {
                const workersQuery = query(collection(firestore, 'workers'), limit(5));
                const workersSnapshot = await getDocs(workersQuery);
                const workers = workersSnapshot.docs.map(doc => ({
                    id: doc.id,
                    ...doc.data()
                }));

                setDashboardData(prev => ({ ...prev, workers }));
            } catch (error) {
                console.log('Collection workers không tồn tại:', error);
            }

            setDashboardData(prev => ({
                ...prev,
                services,
                bookings
            }));

        } catch (error) {
            console.error('Lỗi khi tải dữ liệu dashboard:', error);
        }
    };

    const handleLogout = async () => {
        try {
            await signOut(auth);
            navigate('/admin-login');
        } catch (error) {
            console.error('Lỗi khi đăng xuất:', error);
        }
    };

    const formatDate = (timestamp) => {
        if (!timestamp) return 'N/A';

        let date;
        if (timestamp.toDate) {
            date = timestamp.toDate();
        } else if (timestamp instanceof Date) {
            date = timestamp;
        } else {
            date = new Date(timestamp);
        }

        return date.toLocaleDateString('vi-VN', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const formatCurrency = (amount) => {
        if (!amount) return '0 ₫';
        return new Intl.NumberFormat('vi-VN', {
            style: 'currency',
            currency: 'VND'
        }).format(amount);
    };

    if (loading) {
        return (
            <div className="loading-container">
                <div className="loading-spinner-large"></div>
                <p className="loading-text">Đang tải dữ liệu quản trị...</p>
            </div>
        );
    }

    if (!isAdmin) {
        return null;
    }

    return (
        <div className="admin-dashboard">
            {/* Header */}
            <header className="admin-header">
                <div className="header-content">
                    <div className="header-left">
                        <div className="header-logo">🏠</div>
                        <h1 className="header-title">HomeService Admin</h1>
                    </div>
                    <div className="header-right">
                        <div className="user-info">
                            <span>👋 Xin chào, <strong>{user?.email}</strong></span>
                        </div>
                        <button onClick={handleLogout} className="logout-button">
                            Đăng Xuất
                        </button>
                    </div>
                </div>
            </header>

            {/* Main Content */}
            <main className="admin-main">
                {/* Stats Cards */}
                <div className="stats-grid">
                    <div className="stat-card">
                        <div className="stat-card-content">
                            <div className="stat-icon blue">📋</div>
                            <div className="stat-info">
                                <h3>Tổng Dịch Vụ</h3>
                                <p className="stat-number">{dashboardData.services.length}</p>
                            </div>
                        </div>
                    </div>

                    <div className="stat-card">
                        <div className="stat-card-content">
                            <div className="stat-icon green">📅</div>
                            <div className="stat-info">
                                <h3>Đơn Đặt Lịch</h3>
                                <p className="stat-number">{dashboardData.bookings.length}</p>
                            </div>
                        </div>
                    </div>

                    <div className="stat-card">
                        <div className="stat-card-content">
                            <div className="stat-icon purple">👥</div>
                            <div className="stat-info">
                                <h3>Người Dùng</h3>
                                <p className="stat-number">{dashboardData.users.length}</p>
                            </div>
                        </div>
                    </div>

                    <div className="stat-card">
                        <div className="stat-card-content">
                            <div className="stat-icon orange">🔧</div>
                            <div className="stat-info">
                                <h3>Thợ Sửa Chữa</h3>
                                <p className="stat-number">{dashboardData.workers.length}</p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Content Grid */}
                <div className="content-grid">
                    {/* Services Section */}
                    <div className="content-section">
                        <div className="section-header">
                            <h2 className="section-title">Dịch Vụ Gần Đây</h2>
                        </div>
                        <div className="section-content">
                            {dashboardData.services.length > 0 ? (
                                <div className="services-grid">
                                    {dashboardData.services.map(service => (
                                        <div key={service.id} className="service-card">
                                            <h3>{service.name || 'Tên dịch vụ'}</h3>
                                            <p>{service.description || 'Không có mô tả'}</p>
                                            <div className="service-meta">
                                                <span className="service-price">
                                                    {formatCurrency(service.suggestedPrice || service.minPrice)}
                                                </span>
                                                <span className="service-category">
                                                    {service.category || 'Khác'}
                                                </span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <div className="empty-state">
                                    <div className="empty-state-icon">📋</div>
                                    <p className="empty-state-text">Chưa có dịch vụ nào được tạo</p>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Bookings Section */}
                    <div className="content-section">
                        <div className="section-header">
                            <h2 className="section-title">Đơn Đặt Lịch Gần Đây</h2>
                        </div>
                        <div className="section-content">
                            {dashboardData.bookings.length > 0 ? (
                                <div className="bookings-list">
                                    {dashboardData.bookings.map(booking => (
                                        <div key={booking.id} className="booking-card">
                                            <div className="booking-header">
                                                <h4 className="booking-id">
                                                    Đơn #{booking.id.substring(0, 8)}
                                                </h4>
                                                <span className={`booking-status ${booking.status || 'pending'}`}>
                                                    {booking.status === 'completed' ? 'Hoàn thành' :
                                                        booking.status === 'cancelled' ? 'Đã hủy' : 'Đang chờ'}
                                                </span>
                                            </div>
                                            <div className="booking-details">
                                                <div className="booking-detail">
                                                    <strong>Khách hàng:</strong> {booking.customerName || booking.userName || 'N/A'}
                                                </div>
                                                <div className="booking-detail">
                                                    <strong>Dịch vụ:</strong> {booking.serviceName || booking.serviceType || 'N/A'}
                                                </div>
                                                <div className="booking-detail">
                                                    <strong>Ngày tạo:</strong> {formatDate(booking.createdAt)}
                                                </div>
                                                <div className="booking-detail">
                                                    <strong>Giá trị:</strong> {formatCurrency(booking.totalAmount || booking.price)}
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <div className="empty-state">
                                    <div className="empty-state-icon">📅</div>
                                    <p className="empty-state-text">Chưa có đơn đặt lịch nào</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
};

export default AdminDashboard;