import React from 'react';

const StatusBadge = ({ isActive }) => {
    return (
        <span
            className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${isActive
                    ? 'bg-green-100 text-green-800'
                    : 'bg-red-100 text-red-800'
                }`}
        >
            <span className={`w-1.5 h-1.5 mr-1.5 rounded-full ${isActive ? 'bg-green-400' : 'bg-red-400'}`}></span>
            {isActive ? 'Hoạt động' : 'Tạm ngưng'}
        </span>
    );
};

export default StatusBadge;
