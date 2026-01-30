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

const ServiceManager = () => {
  const { firestore } = useFirebase();
  const [services, setServices] = useState([]);
  const [newService, setNewService] = useState({
    name: '',
    description: '',
    price: '',
    category: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Real-time listener for services collection
  useEffect(() => {
    const unsubscribe = onSnapshot(
      collection(firestore, 'services'),
      (snapshot) => {
        const servicesData = snapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data()
        }));
        setServices(servicesData);
      },
      (error) => {
        console.error('Error listening to services:', error);
      }
    );

    return () => unsubscribe();
  }, [firestore]);

  const addService = async (e) => {
    e.preventDefault();
    if (!newService.name.trim()) return;

    setLoading(true);
    setError('');

    try {
      await addDoc(collection(firestore, 'services'), {
        ...newService,
        price: parseFloat(newService.price),
        createdAt: new Date(),
        status: 'active'
      });
      setNewService({
        name: '',
        description: '',
        price: '',
        category: ''
      });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const updateService = async (id, updatedData) => {
    try {
      const serviceDoc = doc(firestore, 'services', id);
      await updateDoc(serviceDoc, updatedData);
    } catch (err) {
      setError(err.message);
    }
  };

  const deleteService = async (id) => {
    try {
      const serviceDoc = doc(firestore, 'services', id);
      await deleteDoc(serviceDoc);
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="service-manager">
      <h3>Service Management</h3>
      
      <form onSubmit={addService}>
        <div>
          <input
            type="text"
            placeholder="Service Name"
            value={newService.name}
            onChange={(e) => setNewService({...newService, name: e.target.value})}
            disabled={loading}
            required
          />
        </div>
        <div>
          <input
            type="text"
            placeholder="Description"
            value={newService.description}
            onChange={(e) => setNewService({...newService, description: e.target.value})}
            disabled={loading}
          />
        </div>
        <div>
          <input
            type="number"
            placeholder="Price"
            value={newService.price}
            onChange={(e) => setNewService({...newService, price: e.target.value})}
            disabled={loading}
          />
        </div>
        <div>
          <input
            type="text"
            placeholder="Category"
            value={newService.category}
            onChange={(e) => setNewService({...newService, category: e.target.value})}
            disabled={loading}
          />
        </div>
        <button type="submit" disabled={loading}>
          {loading ? 'Adding...' : 'Add Service'}
        </button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}

      <div className="services-list">
        <h4>Services List</h4>
        {services.map(service => (
          <div key={service.id} style={{ border: '1px solid #eee', margin: '10px', padding: '10px' }}>
            <h5>{service.name}</h5>
            <p>{service.description}</p>
            <p>Price: ${service.price}</p>
            <p>Category: {service.category}</p>
            <div>
              <button onClick={() => updateService(service.id, { ...service, status: service.status === 'active' ? 'inactive' : 'active' })}>
                {service.status === 'active' ? 'Deactivate' : 'Activate'}
              </button>
              <button onClick={() => deleteService(service.id)}>Delete</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ServiceManager;