import React, { createContext, useContext, useState, useEffect } from 'react';
import {
    onAuthStateChanged,
    signInWithEmailAndPassword,
    signOut as firebaseSignOut,
    setPersistence,
    browserLocalPersistence
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, firestore } from '../firebase/config';

const AuthContext = createContext();

export const useAuth = () => {
    const context = useContext(AuthContext);
    if (!context) {
        throw new Error('useAuth must be used within an AuthProvider');
    }
    return context;
};

export const AuthProvider = ({ children }) => {
    const [currentUser, setCurrentUser] = useState(null);
    const [userData, setUserData] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        // Set persistence to LOCAL (survives browser restart)
        // Note: Firebase's default is already LOCAL, but setting it explicitly ensures it.
        // For distinct "7 days" logic, we'd need cookies or custom logic, but standard "Remember me"
        // (Local Persistence) is usually what users mean by "keep me logged in".
        setPersistence(auth, browserLocalPersistence)
            .catch((error) => {
                console.error("Auth Persistence Error:", error);
            });

        const unsubscribe = onAuthStateChanged(auth, async (user) => {
            setCurrentUser(user);

            if (user) {
                try {
                    // Fetch additional user data (role, profile info) from Firestore
                    const userDoc = await getDoc(doc(firestore, 'users', user.uid));
                    if (userDoc.exists()) {
                        setUserData(userDoc.data());
                    } else {
                        // Fallback/Simulated admin for predefined emails if db record is missing
                        // This matches the logic from AdminLogin, keeping it consistent
                        const adminEmails = [
                            'admin@homeservice.com',
                            'admin@gmail.com',
                            'nguyenngochiep@gmail.com',
                            'quanly@homeservice.com'
                        ];
                        if (adminEmails.includes(user.email)) {
                            setUserData({ role: 'admin', name: 'Admin User' });
                        } else {
                            setUserData(null);
                        }
                    }
                } catch (error) {
                    console.error("Error fetching user data:", error);
                    setUserData(null);
                }
            } else {
                setUserData(null);
            }

            setLoading(false);
        });

        return unsubscribe;
    }, []);

    const login = (email, password) => {
        return signInWithEmailAndPassword(auth, email, password);
    };

    const logout = () => {
        return firebaseSignOut(auth);
    };

    const value = {
        currentUser,
        userData,
        loading,
        login,
        logout
    };

    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
};

export default AuthContext;
