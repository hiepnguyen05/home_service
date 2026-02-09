import React from 'react';

const StatusBadge = ({ status, type = 'default' }) => {
    // Status mapping configuration
    const config = {
        active: {
            bg: 'bg-green-100',
            text: 'text-green-800',
            dot: 'bg-green-500',
            label: 'Hoạt động'
        },
        approved: {
            bg: 'bg-green-100',
            text: 'text-green-800',
            dot: 'bg-green-500',
            label: 'Đã duyệt'
        },
        pending: {
            bg: 'bg-yellow-100',
            text: 'text-yellow-800',
            dot: 'bg-yellow-500',
            label: 'Chờ duyệt'
        },
        rejected: {
            bg: 'bg-red-100',
            text: 'text-red-800',
            dot: 'bg-red-500',
            label: 'Từ chối'
        },
        locked: {
            bg: 'bg-gray-100',
            text: 'text-gray-800',
            dot: 'bg-gray-500',
            label: 'Đã khóa'
        }
    };

    // Normalize input status to lowercase to match keys
    const normalizedStatus = status?.toLowerCase() || 'pending';
    const style = config[normalizedStatus] || {
        bg: 'bg-gray-100',
        text: 'text-gray-600',
        dot: 'bg-gray-400',
        label: status
    };

    return (
        <span className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-medium ${style.bg} ${style.text}`}>
            <span className={`h-1.5 w-1.5 rounded-full ${style.dot}`}></span>
            <span>{style.label}</span>
        </span>
    );
};

export default StatusBadge;
