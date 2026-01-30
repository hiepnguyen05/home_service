import { getDownloadURL, ref, uploadBytes } from 'firebase/storage';
import { doc, getDoc, setDoc } from 'firebase/firestore';

// Upload file to Firebase Storage
export const uploadFile = async (storage, file, folderPath = 'uploads') => {
  try {
    const storageRef = ref(storage, `${folderPath}/${Date.now()}_${file.name}`);
    const snapshot = await uploadBytes(storageRef, file);
    const downloadURL = await getDownloadURL(snapshot.ref);
    return downloadURL;
  } catch (error) {
    console.error('Error uploading file:', error);
    throw error;
  }
};

// Get document from Firestore
export const getDocument = async (firestore, collectionName, documentId) => {
  try {
    const docRef = doc(firestore, collectionName, documentId);
    const docSnap = await getDoc(docRef);
    
    if (docSnap.exists()) {
      return { id: docSnap.id, ...docSnap.data() };
    } else {
      return null;
    }
  } catch (error) {
    console.error('Error getting document:', error);
    throw error;
  }
};

// Set document in Firestore
export const setDocument = async (firestore, collectionName, documentId, data) => {
  try {
    const docRef = doc(firestore, collectionName, documentId);
    await setDoc(docRef, data, { merge: true });
    return docRef;
  } catch (error) {
    console.error('Error setting document:', error);
    throw error;
  }
};

// Check if user is authenticated
export const isAuthenticated = (auth) => {
  return auth.currentUser !== null;
};

// Get current user
export const getCurrentUser = (auth) => {
  return auth.currentUser;
};