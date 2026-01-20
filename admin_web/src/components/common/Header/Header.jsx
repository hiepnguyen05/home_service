import React from 'react';
import './Header.css';

const Header = ({ title, user }) => {
    return (
        <header className="header">
            <div className="header-left">
                <h1 className="header-title">{title}</h1>
            </div>
            <div className="header-right">
                <div className="user-info">
                    <span className="user-name">{user?.fullName || 'Admin'}</span>
                    <div className="user-avatar">
                        {user?.avatarUrl ? (
                            <img src={user.avatarUrl} alt="Avatar" />
                        ) : (
                            <div className="avatar-placeholder">
                                {user?.fullName?.charAt(0) || 'A'}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </header>
    );
};

export default Header;