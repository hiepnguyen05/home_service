import { firestore } from './src/firebase/config.js';
import { collection, getDocs, limit, query } from 'firebase/firestore';

async function checkUsers() {
    try {
        const q = query(collection(firestore, 'users'), limit(5));
        const snapshot = await getDocs(q);
        snapshot.forEach(doc => {
            console.log(`ID: ${doc.id}`);
            console.log('Data:', JSON.stringify(doc.data(), null, 2));
            console.log('---');
        });
    } catch (e) {
        console.error(e);
    }
}

checkUsers();
