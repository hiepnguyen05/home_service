import React from 'react';
import { FaSearch } from 'react-icons/fa';

export const Input = ({
    label,
    id,
    type = 'text',
    placeholder,
    value,
    onChange,
    error,
    className = '',
    ...props
}) => {
    return (
        <div className={`w-full ${className}`}>
            {label && (
                <label htmlFor={id} className="block text-sm font-medium text-gray-700 mb-1">
                    {label}
                </label>
            )}
            <input
                id={id}
                type={type}
                className={`w-full rounded-lg border bg-white px-3 py-2 text-sm outline-none transition-all
                    ${error
                        ? 'border-red-300 focus:border-red-500 focus:ring-1 focus:ring-red-500'
                        : 'border-gray-200 text-gray-800 placeholder:text-gray-400 focus:border-green-500 focus:ring-1 focus:ring-green-500'
                    }
                `}
                placeholder={placeholder}
                value={value}
                onChange={onChange}
                {...props}
            />
            {error && <p className="mt-1 text-xs text-red-500">{error}</p>}
        </div>
    );
};

export const SearchInput = ({
    placeholder = "Tìm kiếm...",
    value,
    onChange,
    className = ''
}) => {
    return (
        <div className={`relative ${className}`}>
            <FaSearch className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm" />
            <input
                type="text"
                className="h-10 w-full rounded-lg border border-gray-200 bg-white pl-9 pr-4 text-sm text-gray-800 placeholder:text-gray-400 focus:border-green-500 focus:ring-1 focus:ring-green-500 outline-none transition-all"
                placeholder={placeholder}
                value={value}
                onChange={onChange}
            />
        </div>
    );
};

export const Select = ({
    label,
    id,
    options = [], // [{ value, label }]
    value,
    onChange,
    className = '',
    placeholder = "Chọn options"
}) => {
    return (
        <div className={`w-full ${className}`}>
            {label && (
                <label htmlFor={id} className="block text-sm font-medium text-gray-700 mb-1">
                    {label}
                </label>
            )}
            <select
                id={id}
                value={value}
                onChange={onChange}
                className="h-10 w-full rounded-lg border border-gray-200 bg-white px-3 text-sm text-gray-800 focus:border-green-500 focus:ring-1 focus:ring-green-500 outline-none cursor-pointer"
            >
                <option value="" disabled>{placeholder}</option>
                {options.map((opt) => (
                    <option key={opt.value} value={opt.value}>
                        {opt.label}
                    </option>
                ))}
            </select>
        </div>
    );
};
