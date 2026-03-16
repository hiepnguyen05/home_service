import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import PrivateRoute from './components/Auth/PrivateRoute'
import AdminDashboard from './pages/Dashboard/AdminDashboard.jsx'
import CustomerManager from './pages/Customers/CustomerManager.jsx'
import ProviderManager from './pages/Providers/ProviderManager.jsx'
import CategoriesManager from './pages/Categories/CategoriesManager.jsx'
import ServiceManager from './pages/Services/ServiceManager.jsx'
import SettingsManager from './pages/Settings/SettingsManager.jsx'
import WorkerApplications from './pages/WorkerApplications/WorkerApplications.jsx'
import AdminLogin from './pages/Login/AdminLogin.jsx'
import AdminLayout from './layouts/AdminLayout'
import './App.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/admin-login" element={<AdminLogin />} />

          <Route path="/" element={<Navigate to="/dashboard" />} />

          <Route path="/dashboard" element={
            <PrivateRoute>
              <AdminLayout title="Bảng điều khiển"><AdminDashboard /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/customers" element={
            <PrivateRoute>
              <AdminLayout title="Quản lý Khách hàng"><CustomerManager /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/providers" element={
            <PrivateRoute>
              <AdminLayout title="Quản lý Thợ"><ProviderManager /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/applications" element={
            <PrivateRoute>
              <AdminLayout title="Duyệt hồ sơ"><WorkerApplications /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/categories" element={
            <PrivateRoute>
              <AdminLayout title="Quản lý Danh mục"><CategoriesManager /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/services" element={
            <PrivateRoute>
              <AdminLayout title="Dịch vụ"><ServiceManager /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/orders" element={
            <PrivateRoute>
              <AdminLayout title="Đơn hàng"><div>Trang Đơn hàng (Đang phát triển)</div></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/reports" element={
            <PrivateRoute>
              <AdminLayout title="Báo cáo"><div>Trang Báo cáo (Đang phát triển)</div></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="/settings" element={
            <PrivateRoute>
              <AdminLayout title="Cài đặt"><SettingsManager /></AdminLayout>
            </PrivateRoute>
          } />

          <Route path="*" element={<Navigate to="/dashboard" />} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App
