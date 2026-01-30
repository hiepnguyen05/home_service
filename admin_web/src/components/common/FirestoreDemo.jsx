import React, { useState, useEffect } from 'react';
import { useFirebase } from '../../context/FirebaseContext';
import { 
  collection, 
  addDoc, 
  getDocs, 
  updateDoc, 
  deleteDoc, 
  doc,
  onSnapshot 
} from 'firebase/firestore';

const FirestoreDemo = () => {
  const { firestore } = useFirebase();
  const [items, setItems] = useState([]);
  const [newItem, setNewItem] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Real-time listener for Firestore collection
  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(firestore, 'demoItems'),
      (snapshot) => {
        const itemsData = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setItems(itemsData);
      },
      (error) => {
        console.error('Error listening to Firestore:', error);
      }
    );

    return () => unsubscribe();
  }, [firestore]);

  const addItem = async (e) => {
    e.preventDefault();
    if (!newItem.trim()) return;

    setLoading(true);
    setError('');

    try {
      await addDoc(collection(firestore, 'demoItems'), {
        name: newItem,
        createdAt: new Date(),
        status: 'active'
      });
      setNewItem('');
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const updateItem = async (id, newName) => {
    try {
      const itemDoc = doc(firestore, 'demoItems', id);
      await updateDoc(itemDoc, {
        name: newName
      });
    } catch (err) {
      setError(err.message);
    }
  };

  const deleteItem = async (id) => {
    try {
      const itemDoc = doc(firestore, 'demoItems', id);
      await deleteDoc(itemDoc);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="firestore-demo">
      <h3>Firebase Firestore Demo</h3>
      
      <form onSubmit={addItem}>
        <input
          type="text"
          placeholder="Add new item"
          value={newItem}
          onChange={(e) => setNewItem(e.target.value)}
          disabled={loading}
        />
        <button type="submit" disabled={loading}>
          {loading ? 'Adding...' : 'Add Item'}
        </button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}

      <ul>
        {items.map(item => (
          <li key={item.id}>
            <span>{item.name}</span>
            <button onClick={() => updateItem(item.id, prompt('Update item name:', item.name))}>
              Update
            </button>
            <button onClick={() => deleteItem(item.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default FirestoreDemo;