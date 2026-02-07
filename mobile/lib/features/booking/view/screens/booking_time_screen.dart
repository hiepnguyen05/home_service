import 'package:flutter/material.dart';
import '../widgets/time/booking_date_picker.dart';
import '../widgets/common/booking_stepper.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/time/booking_time_slot.dart';
import '../widgets/time/instant_booking_option.dart';
import 'booking_address_screen.dart';

class BookingTimeScreen extends StatefulWidget {
  final String serviceId;
  const BookingTimeScreen({super.key, required this.serviceId});

  @override
  State<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends State<BookingTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final morningSlots = ["07:00", "08:00", "09:00", "10:00", "11:00"];
  final afternoonSlots = ["13:00", "14:00", "15:00", "16:00", "17:00"];
  final eveningSlots = ["18:00", "19:00", "20:00", "21:00", "22:00"];

  /// Lọc danh sách giờ: Chỉ lấy những giờ chưa trôi qua nếu chọn ngày hôm nay
  List<String> _getAvailableSlots(List<String> originalSlots) {
    final now = DateTime.now();

    // Nếu ngày chọn LÀ HÔM NAY -> Phải lọc giờ
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return originalSlots.where((slot) {
        // slot dạng "08:00" -> lấy số 8 để so sánh
        int slotHour = int.parse(slot.split(":")[0]);
        // Tốt nhất nên cho dư ra 1 tiếng để thợ kịp chuẩn bị
        return slotHour > now.hour;
      }).toList();
    }

    // Nếu là ngày mai, ngày kia -> Lấy hết
    return originalSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Chọn ngày giờ"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Thanh tiến trình
            const Center(child: BookingStepper(currentStep: 0)),
            const SizedBox(height: 16),
            const Text(
              "Chọn ngày",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BookingDatePicker(
              selectedDate: _selectedDate,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                });
              },
            ),
            const SizedBox(
              height: 24,
            ),
            // Tùy chọn đặt ngay bây giờ (chỉ hiện nếu chọn hôm nay)
            if (_selectedDate.year == DateTime.now().year &&
                _selectedDate.month == DateTime.now().month &&
                _selectedDate.day == DateTime.now().day)
              InstantBookingOption(
                isSelected: _selectedTime == "Ngay bây giờ",
                onTap: () {
                  setState(() {
                    _selectedDate = DateTime.now();
                    _selectedTime = "Ngay bây giờ";
                  });
                },
              ),

            Container(
              height: 15,
              color: Colors
                  .white, // Separator hack (should be sized box or divider)
            ),
            const Text(
              "Chọn khung giờ",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BookingTimeSlot(
              title: "Buổi sáng",
              timeSlots: morningSlots,
              selectedTime: _selectedTime,
              enabledSlots: _getAvailableSlots(morningSlots),
              onTimeSelected: (time) => setState(() => _selectedTime = time),
            ),
            const SizedBox(height: 24),
            BookingTimeSlot(
              title: "Buổi chiều",
              timeSlots: afternoonSlots,
              selectedTime: _selectedTime,
              enabledSlots: _getAvailableSlots(afternoonSlots),
              onTimeSelected: (time) => setState(() => _selectedTime = time),
            ),
            const SizedBox(height: 24),
            Container(
              height: 8,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            BookingTimeSlot(
              title: "Buổi tối",
              timeSlots: eveningSlots,
              selectedTime: _selectedTime,
              enabledSlots: _getAvailableSlots(eveningSlots),
              onTimeSelected: (time) => setState(() => _selectedTime = time),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _selectedTime != null
              ? () {
                  DateTime bookingTime;

                  // Trường hợp đặc biệt: "Ngay bây giờ" - sử dụng thời gian hiện tại
                  if (_selectedTime == "Ngay bây giờ") {
                    bookingTime = DateTime.now();
                  } else {
                    // Phân tích chuỗi thời gian - định dạng "HH:MM"
                    final timeParts = _selectedTime!.split(':');
                    final hour = int.parse(timeParts[0]);
                    final minute = int.parse(timeParts[1]);

                    bookingTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour,
                      minute,
                    );
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingAddressScreen(
                        serviceId: widget.serviceId,
                        bookingTime: bookingTime,
                      ),
                    ),
                  );
                }
              : null, // Disable nút khi chưa chọn giờ
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: Colors.grey[300],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            "Tiếp theo",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
