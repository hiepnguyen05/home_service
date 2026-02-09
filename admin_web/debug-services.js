import { initializeApp } from "firebase/app";
import { getFirestore, collection, getDocs } from "firebase/firestore";
import { firestore } from './src/firebase/config.js'; // Adjust path as needed

async function checkServices() {
    console.log("Fetching services...");
    try {
        const querySnapshot = await getDocs(collection(firestore, "services"));
        if (querySnapshot.empty) {
            console.log("No services found.");
            return;
        }

        querySnapshot.forEach((doc) => {
            console.log(doc.id, " => ", doc.data());
        });
    } catch (error) {
        console.error("Error getting services:", error);
    }
}

checkServices();
