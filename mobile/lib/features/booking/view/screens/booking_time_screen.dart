import 'package:flutter/material.dart';
import 'package:mobile/features/booking/view/widgets/booking_date_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/booking_time_slot.dart';

class BookingTimeScreen extends StatefulWidget {
  const BookingTimeScreen({super.key});

  @override
  State<BookingTimeScreen> createState() => _BookingTimeScreenState();
}

class _BookingTimeScreenState extends State<BookingTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final morningSlots = ["07:00", "08:00", "09:00", "10:00", "11:00"];
  final afternoonSlots = ["13:00", "14:00", "15:00", "16:00", "17:00"];
  final eveningSlots = ["18:00", "19:00", "20:00", "21:00", "22:00"];
  // Hàm lọc danh sách giờ: Chỉ lấy những giờ chưa trôi qua
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
            if (_selectedDate.year == DateTime.now().year &&
                _selectedDate.month == DateTime.now().month &&
                _selectedDate.day == DateTime.now().day)
              InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = DateTime.now();
                      _selectedTime = "Ngay bây giờ";
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                            color: _selectedTime == "Ngay bây giờ"
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                width: 2.0,
                                color: _selectedTime == "Ngay bây giờ"
                                    ? AppColors.primary
                                    : AppColors.primary)),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: _selectedTime == "Ngay bây giờ"
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                            Text(
                              "Đặt lịch ngay bây giờ",
                              style: TextStyle(
                                color: _selectedTime == "Ngay bây giờ"
                                    ? Colors.white
                                    : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Dành cho khách hàng cần dịch vụ ngay lập tức",
                        style: TextStyle(color: AppColors.textHint),
                      )
                    ],
                  )),
            Container(
              height: 15,
              color: Colors.white,
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
                  // TODO: Chuyển sang màn hình Tiếp theo
                  print(
                      "Lịch đặt: ${_selectedDate.day}/${_selectedDate.month} lúc $_selectedTime");
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
