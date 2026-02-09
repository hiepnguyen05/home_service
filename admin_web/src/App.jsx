import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import CustomerManager from './pages/Customers/CustomerManager.jsx'
import ProviderManager from './pages/Providers/ProviderManager.jsx'
import AdminLayout from './layouts/AdminLayout'
import './App.css'

// Uncomment dòng dưới để test Firebase connection
// import { testFirebaseConnection } from './utils/testFirebase';
// testFirebaseConnection();

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Navigate to="/customers" />} />
        <Route path="/customers" element={<AdminLayout title="Quản lý Khách hàng"><CustomerManager /></AdminLayout>} />
        <Route path="/providers" element={<AdminLayout title="Quản lý Thợ"><ProviderManager /></AdminLayout>} />
        <Route path="/categories" element={<AdminLayout title="Quản lý Danh mục"><div>Trang Quản lý Danh mục (Đang phát triển)</div></AdminLayout>} />
        <Route path="/services" element={<AdminLayout title="Dịch vụ"><div>Trang Dịch vụ (Đang phát triển)</div></AdminLayout>} />
        <Route path="/orders" element={<AdminLayout title="Đơn hàng"><div>Trang Đơn hàng (Đang phát triển)</div></AdminLayout>} />
        <Route path="/reports" element={<AdminLayout title="Báo cáo"><div>Trang Báo cáo (Đang phát triển)</div></AdminLayout>} />
        <Route path="/settings" element={<AdminLayout title="Cài đặt"><div>Trang Cài đặt (Đang phát triển)</div></AdminLayout>} />
        <Route path="*" element={<Navigate to="/customers" />} />
      </Routes>
    </Router>
  )
}

export default App
