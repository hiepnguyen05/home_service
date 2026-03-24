import React, { useEffect, useState } from 'react';
import { collection, documentId, getDocs, orderBy, query, where } from 'firebase/firestore';
import { firestore } from '../../firebase/config';

const STATUS_LABELS = {
  pending: 'Chờ xác nhận',
  accepted: 'Đã nhận',
  confirmed: 'Đã xác nhận',
  waitingPayment: 'Chờ thanh toán',
  processing: 'Đang xử lý',
  arrived: 'Đã đến',
  paused: 'Tạm dừng',
  completed: 'Hoàn thành',
  cancelled: 'Đã hủy'
};

const STATUS_STYLES = {
  pending: 'bg-amber-100 text-amber-700 border-amber-200',
  accepted: 'bg-blue-100 text-blue-700 border-blue-200',
  confirmed: 'bg-green-100 text-green-700 border-green-200',
  waitingPayment: 'bg-amber-100 text-amber-700 border-amber-200',
  processing: 'bg-indigo-100 text-indigo-700 border-indigo-200',
  arrived: 'bg-cyan-100 text-cyan-700 border-cyan-200',
  paused: 'bg-slate-100 text-slate-700 border-slate-200',
  completed: 'bg-emerald-100 text-emerald-700 border-emerald-200',
  cancelled: 'bg-red-100 text-red-700 border-red-200'
};

const chunkArray = (arr, size = 10) => {
  const chunks = [];
  for (let i = 0; i < arr.length; i += size) {
    chunks.push(arr.slice(i, i + size));
  }
  return chunks;
};

const fetchCollectionMap = async (collectionPath, ids) => {
  const map = {};
  if (!ids.length) {
    return map;
  }

  const chunks = chunkArray(ids);
  for (const chunk of chunks) {
    const q = query(collection(firestore, collectionPath), where(documentId(), 'in', chunk));
    const snapshot = await getDocs(q);
    snapshot.docs.forEach((doc) => {
      map[doc.id] = doc.data();
    });
  }
  return map;
};

const BookingManager = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    fetchBookings();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchBookings = async () => {
    try {
      setLoading(true);
      setError(null);

      const bookingsRef = collection(firestore, 'bookings');
      const bookingsQuery = query(bookingsRef, orderBy('scheduleAt', 'desc'));
      const snapshot = await getDocs(bookingsQuery);
      const rawBookings = snapshot.docs.map((doc) => {
        const raw = doc.data();
        const scheduleAt = raw.scheduleAt
          ? raw.scheduleAt.toDate
            ? raw.scheduleAt.toDate()
            : new Date(raw.scheduleAt)
          : null;

        return {
          id: doc.id,
          scheduleAt,
          customerId: raw.customerId || '---',
          serviceId: raw.serviceId || '---',
          providerId: raw.providerId || '',
          address: raw.address || '---',
          status: raw.status || 'pending',
          totalPrice: Number(raw.totalPrice) || 0,
          paymentMethod: raw.paymentMethod || 'COD',
          customerName: raw.customerName || raw.fullName || '',
          ...raw
        };
      });

      const customerIds = [
        ...new Set(rawBookings.map((booking) => booking.customerId).filter(Boolean))
      ].filter(id => id !== '---');
      
      const serviceIds = [
        ...new Set(rawBookings.map((booking) => booking.serviceId).filter(Boolean))
      ].filter(id => id !== '---');
      
      const providerIds = [
        ...new Set(rawBookings.map((booking) => booking.providerId).filter(Boolean))
      ].filter(id => id && id !== '---');

      const [customerMap, serviceMap, providerMap] = await Promise.all([
        fetchCollectionMap('users', customerIds),
        fetchCollectionMap('services', serviceIds),
        fetchCollectionMap('users', providerIds)
      ]);

      const resolveName = (user) => {
        if (!user) return null;
        return user.fullName || user.full_name || user.name || user.displayName || null;
      };

      const enriched = rawBookings.map((booking) => ({
        ...booking,
        customerResolvedName:
          resolveName(customerMap[booking.customerId]) ||
          booking.customerName ||
          booking.customerId,
        serviceName: serviceMap[booking.serviceId]?.name || booking.serviceId,
        providerResolvedName:
          resolveName(providerMap[booking.providerId]) ||
          booking.providerName ||
          (booking.providerId ? booking.providerId : 'Chưa có thợ')
      }));

      setBookings(enriched);
    } catch (err) {
      console.error('Error fetching bookings:', err);
      setError('Không thể tải danh sách đơn đặt lịch. Vui lòng thử lại sau.');
    } finally {
      setLoading(false);
    }
  };

  const filteredBookings = bookings.filter((booking) => {
    const term = searchTerm.toLowerCase();
    const matchesSearch =
      booking.id.toLowerCase().includes(term) ||
      booking.customerResolvedName.toLowerCase().includes(term) ||
      (booking.serviceName && booking.serviceName.toLowerCase().includes(term)) ||
      (booking.address && booking.address.toLowerCase().includes(term));

    const matchesStatus =
      selectedStatus === 'all' || booking.status === selectedStatus;

    return matchesSearch && matchesStatus;
  });

  const itemsPerPage = 10;
  const totalPages = Math.max(1, Math.ceil(filteredBookings.length / itemsPerPage));
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const paginatedBookings = filteredBookings.slice(startIndex, endIndex);

  const formatCurrency = (value) =>
    new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(value);

  const formatDateTime = (date) => {
    if (!date) return 'Chưa đặt lịch';
    return new Intl.DateTimeFormat('vi-VN', {
      weekday: 'short',
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  const handleCopyId = (id) => {
    navigator.clipboard.writeText(id);
  };

  const resetFilters = () => {
    setSearchTerm('');
    setSelectedStatus('all');
    setCurrentPage(1);
  };

  const StatusBadge = ({ status }) => (
    <span className={`px-2.5 py-0.5 rounded-full text-[11px] font-bold uppercase tracking-wider border ${STATUS_STYLES[status] ?? 'bg-slate-100 text-slate-600 border-slate-200'}`}>
      {STATUS_LABELS[status] || status}
    </span>
  );

  return (
    <div className="flex-1 flex flex-col bg-slate-50 dark:bg-slate-950 min-w-0">
      <div className="p-4 md:p-8 space-y-6 max-w-[1600px] mx-auto w-full">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <h2 className="text-2xl md:text-3xl font-extrabold tracking-tight text-slate-900 dark:text-white">
              Quản lý đơn đặt lịch
            </h2>
            <p className="text-slate-500 dark:text-slate-400 mt-1 text-sm md:text-base">
              Theo dõi và quản lý tập trung tất cả các đơn đặt lịch trên hệ thống.
            </p>
          </div>
          <button
            onClick={resetFilters}
            className="flex items-center justify-center gap-2 px-4 py-2 rounded-lg bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-sm font-semibold text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-all shadow-sm"
          >
            <span className="material-symbols-outlined text-lg">filter_alt_off</span>
            Đặt lại bộ lọc
          </button>
        </div>

        {error && (
          <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl p-4 flex items-center gap-3 animate-in fade-in slide-in-from-top-4">
            <span className="material-symbols-outlined text-red-600">error</span>
            <p className="text-red-600 dark:text-red-400 text-sm font-medium">{error}</p>
            <button onClick={fetchBookings} className="ml-auto text-xs font-bold uppercase tracking-wider text-red-700 hover:underline">
              Thử lại
            </button>
          </div>
        )}

        {/* Search & Filters */}
        <div className="bg-white dark:bg-slate-900 p-4 rounded-2xl border border-slate-200 dark:border-slate-800 flex flex-col lg:flex-row gap-4 items-stretch lg:items-center shadow-sm">
          <div className="relative flex-1">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">search</span>
            <input
              type="text"
              value={searchTerm}
              onChange={(event) => { setSearchTerm(event.target.value); setCurrentPage(1); }}
              placeholder="Tìm kiếm theo ID, khách hàng, dịch vụ hoặc địa chỉ..."
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-green-500 focus:border-green-500 text-sm placeholder:text-slate-400 transition-all outline-none"
            />
          </div>
          <div className="relative min-w-[200px]">
            <select
              className="w-full appearance-none pl-4 pr-10 py-2.5 bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700 rounded-xl focus:ring-2 focus:ring-green-500 text-sm font-semibold outline-none cursor-pointer"
              value={selectedStatus}
              onChange={(event) => {
                setSelectedStatus(event.target.value);
                setCurrentPage(1);
              }}
            >
              <option value="all">Tất cả trạng thái</option>
              {Object.keys(STATUS_LABELS).map((status) => (
                <option key={status} value={status}>
                  {STATUS_LABELS[status]}
                </option>
              ))}
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">
              unfold_more
            </span>
          </div>
        </div>

        {/* Mobile View (Cards) */}
        <div className="lg:hidden space-y-4">
          {loading ? (
            <div className="p-10 text-center animate-pulse text-slate-400 flex flex-col items-center gap-2">
              <div className="size-8 border-4 border-green-500 border-t-transparent rounded-full animate-spin"></div>
              <span>Đang tải đơn đặt lịch...</span>
            </div>
          ) : paginatedBookings.length === 0 ? (
            <div className="bg-white dark:bg-slate-900 border border-dashed border-slate-300 dark:border-slate-700 rounded-2xl p-10 text-center text-slate-500">
              {searchTerm || selectedStatus !== 'all' ? 'Không tìm thấy kết quả phù hợp.' : 'Chưa có đơn đặt lịch nào.'}
            </div>
          ) : (
            paginatedBookings.map((booking) => (
              <div key={booking.id} className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200 dark:border-slate-800 p-5 shadow-sm space-y-4">
                <div className="flex justify-between items-start">
                  <div className="space-y-1">
                    <p className="text-[10px] uppercase font-bold text-slate-400 tracking-tighter flex items-center gap-1">
                      ID: {booking.id.slice(0, 8)}...
                      <button onClick={() => handleCopyId(booking.id)} className="hover:text-slate-600 transition-colors">
                        <span className="material-symbols-outlined text-xs">content_copy</span>
                      </button>
                    </p>
                    <h4 className="font-bold text-slate-900 dark:text-white leading-tight">{booking.serviceName}</h4>
                  </div>
                  <StatusBadge status={booking.status} />
                </div>
                
                <div className="grid grid-cols-2 gap-4 pt-2">
                  <div className="space-y-0.5">
                    <p className="text-[10px] uppercase font-bold text-slate-400 leading-none">Khách hàng</p>
                    <p className="text-sm font-semibold truncate">{booking.customerResolvedName}</p>
                  </div>
                  <div className="space-y-0.5 text-right">
                    <p className="text-[10px] uppercase font-bold text-slate-400 leading-none">Thợ</p>
                    <p className="text-sm font-semibold truncate">{booking.providerResolvedName}</p>
                  </div>
                  <div className="space-y-0.5">
                    <p className="text-[10px] uppercase font-bold text-slate-400 leading-none">Thời gian</p>
                    <p className="text-xs font-medium">{formatDateTime(booking.scheduleAt)}</p>
                  </div>
                  <div className="space-y-0.5 text-right">
                    <p className="text-[10px] uppercase font-bold text-slate-400 leading-none">Tổng tiền</p>
                    <p className="text-sm font-bold text-green-600">{formatCurrency(booking.totalPrice)}</p>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Desktop View (Table) */}
        <div className="hidden lg:block bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 rounded-2xl overflow-hidden shadow-sm">
          <div className="overflow-x-auto overflow-y-hidden">
            <table className="w-full text-left border-collapse min-w-[1000px]">
              <thead className="bg-slate-50 dark:bg-slate-800/50 border-b border-slate-200 dark:border-slate-800">
                <tr>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500">Mã đơn</th>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500">Dịch vụ & Khách hàng</th>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500">Thợ thực hiện</th>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500">Thời gian & Địa chỉ</th>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500 text-right">Tổng thanh toán</th>
                  <th className="px-6 py-4 text-[11px] font-bold uppercase tracking-widest text-slate-500 text-center">Trạng thái</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {loading ? (
                  <tr>
                    <td colSpan="6" className="px-6 py-20 text-center text-slate-400">
                      <div className="flex flex-col items-center justify-center gap-3">
                        <div className="animate-spin size-8 border-4 border-green-500 border-t-transparent rounded-full"></div>
                        <span className="font-medium">Đang tải dữ liệu...</span>
                      </div>
                    </td>
                  </tr>
                ) : paginatedBookings.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="px-6 py-20 text-center text-slate-500 font-medium">
                      {searchTerm || selectedStatus !== 'all'
                        ? 'Không tìm thấy đơn nào khớp với bộ lọc tìm kiếm.'
                        : 'Hiện tại chưa có bất kỳ đơn đặt lịch nào.'}
                    </td>
                  </tr>
                ) : (
                  paginatedBookings.map((booking) => (
                    <tr key={booking.id} className="hover:bg-slate-50/50 dark:hover:bg-slate-800/20 transition-colors group">
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2 group-hover:translate-x-1 transition-transform">
                          <span className="font-mono text-[11px] font-bold text-slate-400 bg-slate-50 dark:bg-slate-800 px-2 py-1 rounded">
                            {booking.id.slice(0, 8)}
                          </span>
                          <button
                            title="Sao chép ID"
                            onClick={() => handleCopyId(booking.id)}
                            className="text-slate-300 hover:text-slate-600 transition-colors"
                          >
                            <span className="material-symbols-outlined text-sm">content_copy</span>
                          </button>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div>
                          <p className="text-sm font-bold text-slate-900 dark:text-white leading-tight">{booking.serviceName}</p>
                          <p className="text-xs font-semibold text-green-600 mt-0.5">{booking.customerResolvedName}</p>
                        </div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-2">
                           <div className="size-7 rounded-full bg-slate-100 dark:bg-slate-800 flex items-center justify-center text-[10px] font-bold text-slate-500">
                             {booking.providerResolvedName.charAt(0).toUpperCase()}
                           </div>
                           <p className="text-xs font-bold text-slate-700 dark:text-slate-200">{booking.providerResolvedName}</p>
                        </div>
                      </td>
                      <td className="px-6 py-4 max-w-[200px]">
                        <p className="text-xs font-bold text-slate-900 dark:text-white">{formatDateTime(booking.scheduleAt)}</p>
                        <p className="text-[10px] text-slate-500 line-clamp-1 mt-0.5">{booking.address}</p>
                      </td>
                      <td className="px-6 py-4 text-right">
                        <div>
                          <p className="text-sm font-extrabold text-slate-900 dark:text-white">
                            {formatCurrency(booking.totalPrice)}
                          </p>
                          <p className="text-[10px] font-bold text-slate-400 uppercase">{booking.paymentMethod}</p>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <StatusBadge status={booking.status} />
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Pagination */}
        {filteredBookings.length > itemsPerPage && (
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4 pt-4 border-t border-slate-200 dark:border-slate-800">
            <p className="text-xs text-slate-500 font-bold uppercase tracking-tight">
              Hiển thị <span className="text-slate-900 dark:text-white px-1">{Math.min(startIndex + 1, filteredBookings.length)} - {Math.min(endIndex, filteredBookings.length)}</span> 
              của <span className="text-slate-900 dark:text-white px-1">{filteredBookings.length}</span> đơn
            </p>
            <div className="flex items-center gap-2">
              <button
                className="size-9 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 text-slate-600 hover:bg-slate-50 disabled:opacity-30 transition-all flex items-center justify-center shadow-sm"
                disabled={currentPage === 1}
                onClick={() => { setCurrentPage((page) => Math.max(1, page - 1)); window.scrollTo({ top: 0, behavior: 'smooth' }); }}
              >
                <span className="material-symbols-outlined">chevron_left</span>
              </button>
              
              <div className="flex items-center gap-1.5 px-2">
                {[...Array(totalPages)].map((_, i) => {
                  const page = i + 1;
                  // Only show current, neighbors, first and last
                  if (page === 1 || page === totalPages || (page >= currentPage - 1 && page <= currentPage + 1)) {
                    return (
                      <button
                        key={page}
                        className={`size-9 rounded-xl text-xs font-black transition-all shadow-sm ${currentPage === page ? 'bg-green-600 text-white shadow-green-500/20' : 'bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 text-slate-600 hover:bg-slate-50'}`}
                        onClick={() => { setCurrentPage(page); window.scrollTo({ top: 0, behavior: 'smooth' }); }}
                      >
                        {page}
                      </button>
                    );
                  }
                  if (page === currentPage - 2 || page === currentPage + 2) return <span key={page} className="text-slate-400">...</span>;
                  return null;
                })}
              </div>

              <button
                className="size-9 rounded-xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-slate-900 text-slate-600 hover:bg-slate-50 disabled:opacity-30 transition-all flex items-center justify-center shadow-sm"
                disabled={currentPage === totalPages}
                onClick={() => { setCurrentPage((page) => Math.min(totalPages, page + 1)); window.scrollTo({ top: 0, behavior: 'smooth' }); }}
              >
                <span className="material-symbols-outlined">chevron_right</span>
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default BookingManager;
