import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const PrivateRoute = ({ children }) => {
    const { currentUser, userData, loading } = useAuth();

    if (loading) {
        return (
            <div className="flex items-center justify-center h-screen bg-gray-50">
                <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
            </div>
        );
    }

    if (!currentUser) {
        return <Navigate to="/admin-login" />;
    }

    // Optional: Check strictly for admin role
    const isAdmin = userData?.role === 'admin' ||
        userData?.role === 'administrator' ||
        ['admin@homeservice.com', 'admin@gmail.com', 'nguyenngochiep@gmail.com', 'quanly@homeservice.com'].includes(currentUser.email);

    if (!isAdmin) {
        // If logged in but not admin, redirect to login with a warning or show unauthorized
        // For now, redirect to login
        return <Navigate to="/admin-login" />;
    }

    return children;
};

export default PrivateRoute;
