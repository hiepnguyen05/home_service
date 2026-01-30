// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyB592qKGBsbiUyf828Le4xf-3Lo_HGkybQ",
  authDomain: "homeservice-a4290.firebaseapp.com",
  databaseURL: "https://homeservice-a4290-default-rtdb.asia-southeast1.firebasedatabase.app",
  projectId: "homeservice-a4290",
  storageBucket: "homeservice-a4290.firebasestorage.app",
  messagingSenderId: "272138338916",
  appId: "1:272138338916:web:1da01e15bea88126475571",
  measurementId: "G-94CZ3Q2FLL"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);
const auth = getAuth(app);
const firestore = getFirestore(app);
const storage = getStorage(app);

export { app, analytics, auth, firestore, storage };