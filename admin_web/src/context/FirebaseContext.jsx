import React, { createContext, useContext } from 'react';
import { 
  app, 
  analytics, 
  auth, 
  firestore, 
  storage 
} from '../firebase/config';

const FirebaseContext = createContext();

export const useFirebase = () => {
  const context = useContext(FirebaseContext);
  if (!context) {
    throw new Error('useFirebase must be used within a FirebaseProvider');
  }
  return context;
};

export const FirebaseProvider = ({ children }) => {
  const firebaseServices = {
    app,
    analytics,
    auth,
    firestore,
    storage
  };

  return (
    <FirebaseContext.Provider value={firebaseServices}>
      {children}
    </FirebaseContext.Provider>
  );
};