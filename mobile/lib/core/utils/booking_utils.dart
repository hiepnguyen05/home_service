import 'package:intl/intl.dart';

class BookingUtils {
  /// Tính toán thời gian thợ đến (giả lập hoặc dựa trên data thật)
  /// Trả về chuỗi hiển thị, ví dụ: "15 phút", "14:30 hôm nay"
  static String calculateArrivalTime(DateTime bookingTime) {
    final now = DateTime.now();
    final difference = bookingTime.difference(now);

    // Nếu đặt lịch ngay bây giờ hoặc trong quá khứ gần (đang đến)
    if (difference.inMinutes <= 0 || difference.inMinutes < 60) {
      // Giả lập thời gian di chuyển từ 10-20 phút
      return "15 phút";
    }

    // Nếu đặt trong ngày hôm nay
    if (bookingTime.year == now.year &&
        bookingTime.month == now.month &&
        bookingTime.day == now.day) {
      return DateFormat('HH:mm').format(bookingTime);
    }

    // Nếu đặt ngày khác
    return DateFormat('HH:mm dd/MM').format(bookingTime);
  }

  /// Format mã đơn hàng
  static String formatBookingId(String id) {
    if (id.startsWith('#')) return id;
    return '#$id';
  }
}
