/// Các hằng số liên quan đến network và API
class NetworkConstants {
  // Timeout constants
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // File upload constants
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/webp'
  ];
  
  // Retry constants
  static const int maxRetryAttempts = 3;
  static const int retryDelay = 1000; // 1 second
  
  // Cache constants
  static const int cacheMaxAge = 300; // 5 minutes
  static const int cacheMaxStale = 86400; // 24 hours
  
  // Error messages
  static const String networkErrorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
  static const String timeoutErrorMessage = 'Kết nối quá thời gian chờ. Vui lòng thử lại.';
  static const String serverErrorMessage = 'Lỗi server. Vui lòng thử lại sau.';
  static const String unknownErrorMessage = 'Đã xảy ra lỗi không xác định.';
  
  // Firebase Storage paths
  static const String avatarsPath = 'avatars';
  static const String documentsPath = 'documents';
  static const String imagesPath = 'images';
  
  // Firestore collections
  static const String usersCollection = 'users';
  static const String addressesCollection = 'addresses';
  static const String servicesCollection = 'services';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
}