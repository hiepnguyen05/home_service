import React from 'react';

const Button = ({
    children,
    onClick,
    variant = 'primary', // primary, secondary, danger, ghost, outline
    size = 'md', // sm, md, lg
    className = '',
    disabled = false,
    type = 'button',
    icon: Icon
}) => {
    const baseStyles = "inline-flex items-center justify-center gap-2 rounded-lg font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-1 disabled:opacity-50 disabled:cursor-not-allowed";

    const variants = {
        primary: "bg-green-600 text-white hover:bg-green-700 focus:ring-green-500",
        secondary: "bg-gray-100 text-gray-700 hover:bg-gray-200 focus:ring-gray-500",
        danger: "bg-red-50 text-red-600 hover:bg-red-100 focus:ring-red-500 border border-red-200",
        ghost: "bg-transparent text-gray-600 hover:bg-gray-100 hover:text-gray-900",
        outline: "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 focus:ring-gray-400"
    };

    const sizes = {
        sm: "px-3 py-1.5 text-xs",
        md: "px-4 py-2 text-sm",
        lg: "px-6 py-3 text-base"
    };

    return (
        <button
            type={type}
            className={`${baseStyles} ${variants[variant]} ${sizes[size]} ${className}`}
            onClick={onClick}
            disabled={disabled}
        >
            {Icon && <Icon className="text-lg" />}
            {children}
        </button>
    );
};

export default Button;
