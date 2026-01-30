import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AdminLogin } from './pages/Login/index.jsx'
import { AdminDashboard } from './pages/Dashboard/index.jsx'
import ServiceManager from './pages/Services/ServiceManager.jsx'
import './App.css'

import AdminLayout from './components/Layout/AdminLayout';
import CategoriesManager from './pages/Categories/CategoriesManager';
import { WorkerApplications } from './pages/WorkerApplications';

function App() {
  return (
    <Router>
      <Routes>
        {/* Trang chủ mặc định chuyển hướng đến trang đăng nhập admin */}
        <Route path="/" element={<Navigate to="/admin-login" />} />
        {/* Trang đăng nhập admin */}
        <Route path="/admin-login" element={<AdminLogin />} />

        {/* Các trang Admin cần Layout */}
        <Route path="/admin-dashboard" element={
          <AdminLayout>
            <AdminDashboard />
          </AdminLayout>
        } />

        <Route path="/services" element={
          <AdminLayout>
            <ServiceManager />
          </AdminLayout>
        } />

        <Route path="/categories" element={
          <AdminLayout>
            <CategoriesManager />
          </AdminLayout>
        } />

        <Route path="/worker-applications" element={
          <AdminLayout>
            <WorkerApplications />
          </AdminLayout>
        } />

        {/* Redirect for convenience during dev */}
        <Route path="/admin" element={<Navigate to="/admin-dashboard" />} />
      </Routes>
    </Router>
  )
}

export default App
