import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Vẫn giữ để listen booking status trong dialog

import 'package:mobile/core/constants/app_colors.dart';
import 'package:mobile/core/widgets/app_dialog.dart';
import 'package:mobile/features/booking/data/models/booking_model.dart';
import 'package:mobile/features/booking/data/repositories/booking_repository.dart'; // import tạm để dùng BookingStatus consts, có thể move vào model
// Import ViewModel
import 'package:mobile/features/provider/viewmodel/provider_viewmodel.dart';
import 'package:mobile/features/wallet/viewmodel/wallet_viewmodel.dart';

// Widgets
import '../widgets/dashboard/dashboard_header.dart';
import '../widgets/dashboard/dashboard_stats.dart';
import '../widgets/dashboard/income_card.dart';
import '../widgets/dashboard/upcoming_jobs_list.dart';
import '../widgets/jobs/new_job_request_dialog.dart';
import '../widgets/jobs/provider_waiting_payment_dialog.dart';
import 'provider_order_success_screen.dart'; // Added

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  // Stream subscription cho job requests (vẫn cần lắng nghe ở View để hiện dialog)
  StreamSubscription<BookingModel>? _jobRequestSubscription;

  // Trạng thái dialog
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Load dữ liệu được quản lý bởi ProviderMainScreen
    // Chúng ta chỉ cần lắng nghe stream để hiện dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final vm = context.read<ProviderViewModel>();
      
      // Lắng nghe stream từ ViewModel để hiện dialog
      _jobRequestSubscription = vm.newJobRequestStream.listen((booking) {
        // Chỉ hiện dialog nếu chưa hiện
        if (!_isDialogShowing && mounted) {
          _showJobRequestDialog(booking);
        }
      });
    });
  }

  @override
  void dispose() {
    _jobRequestSubscription?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await context.read<ProviderViewModel>().refreshData();
  }

  /// Hiển thị Dialog yêu cầu công việc mới
  void _showJobRequestDialog(BookingModel booking) {
    _isDialogShowing = true;

    // Lắng nghe trạng thái booking real-time (để biết khi khách hủy)
    // Logic này liên quan trực tiếp đến UI (đóng dialog) nên giữ ở View
    StreamSubscription<DocumentSnapshot>? bookingStatusSub;
    bookingStatusSub = FirebaseFirestore.instance
        .collection('bookings')
        .doc(booking.id)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;
      final status = doc.data()?['status'] as String?;

      if (status == BookingStatus.cancelled) {
        // Khách hàng đã hủy -> Tự động đóng dialog
        bookingStatusSub?.cancel();
        if (_isDialogShowing && mounted) {
          Navigator.of(context, rootNavigator: true).pop(); // Đóng dialog
          _isDialogShowing = false;
          context.read<ProviderViewModel>().refreshData(); // Refresh UI

          // Hiện thông báo khách đã hủy
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  const Text("Yêu cầu đã bị hủy"),
                ],
              ),
              content: const Text(
                "Khách hàng đã hủy yêu cầu này.",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Đã hiểu"),
                ),
              ],
            ),
          );
        }
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return NewJobRequestDialog(
          booking: booking,
          onAccept: () async {
            bookingStatusSub?.cancel(); // Hủy listener status
            
            // NEW: Kiểm tra số dư ví trước khi chấp nhận
            if (mounted) {
              final walletVm = Provider.of<WalletViewModel>(context, listen: false);
              final balance = walletVm.wallet?.balance ?? 0;
              if (balance <= 0) {
                _isDialogShowing = false;
                Navigator.pop(ctx);
                DialogUtils.showError(context, 
                  title: "Không thể nhận việc", 
                  message: "Số dư ví của bạn không đủ để nhận việc mới. Vui lòng nạp thêm tiền.");
                return;
              }
            }

            Navigator.pop(ctx);
            _isDialogShowing = false;

            // Xử lý logic chấp nhận (Dựa vào loại đơn hàng)
            // Logic này có thể move vào ViewModel nếu phức tạp hơn,
            // nhưng hiện tại ViewModel hỗ trợ các hàm update status cơ bản.
            // Ta sẽ gọi trực tiếp Repo thông qua ViewModel hoặc xử lý logic quyết định ở đây.
            // Để đúng chuẩn MVVM, ViewModel nên có hàm 'acceptBooking(booking)' xử lý hết logic này.
            // Tuy nhiên, logic này có điều hướng UI (hiện dialog khác), nên xử lý ở View kết hợp ViewModel.

            // Cách tốt nhất: ViewModel trả về trạng thái/loại kết quả, View hiển thị tương ứng.
            // Ở giai đoạn refactor này, ta sẽ gọi BookingRepository trực tiếp hoặc qua ViewModel helper.
            // NHƯNG ViewModel hiện tại chưa có 'acceptBooking'.
            // Ta sẽ dùng BookingRepository trực tiếp ở đây vì ViewModel chưa cover hết logic điều hướng phức tạp này.
            // Hoặc tốt hơn: thêm method vào ViewModel sau. (Hiện tại ViewModel chỉ có toggleOnlineStatus).
            // Ta sẽ dùng trực tiếp BookingRepository ở đây (tương tự code cũ) nhưng reload data qua ViewModel.
            // CHỜ CHÚT: Nguyên lý SOLID bảo không viết logic ở View.
            // Code cũ có logic check 'paymentMethod' và 'priceUnit' để quyết định flow.
            // Logic này NÊN ở ViewModel.

            // Nhưng để nhanh gọn và an toàn, ta giữ logic điều hướng ở đây,
            // chỉ thay các gọi hàm update data bằng gọi Repository (đã import).
            // ViewModel sẽ được gọi để refresh data sau đó.

            final BookingRepository bookingRepo = BookingRepository();

            if (booking.priceUnit == 'giờ') {
              // Tính giờ -> Đã nhận việc
              await bookingRepo.updateBookingStatus(
                  booking.id, BookingStatus.confirmed);
              if (mounted) context.read<ProviderViewModel>().refreshData();
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProviderOrderSuccessScreen(booking: booking),
                  ),
                );
              }
            } else {
              // Giá cố định -> Check thanh toán
              if (booking.paymentMethod == "E-wallet" ||
                  booking.paymentMethod == "Thanh toán Online") {
                await bookingRepo.updateBookingStatus(
                    booking.id, BookingStatus.waitingPayment);
                if (mounted) context.read<ProviderViewModel>().refreshData();

                if (mounted) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => ProviderWaitingPaymentDialog(
                            bookingId: booking.id,
                            onPaymentSuccess: () {
                              Navigator.pop(ctx);
                              if (mounted) context.read<ProviderViewModel>().refreshData();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProviderOrderSuccessScreen(
                                          booking: booking),
                                ),
                              );
                            },
                            onPaymentFailed: (reason) {
                              Navigator.pop(ctx);
                              if (mounted) context.read<ProviderViewModel>().refreshData();
                              DialogUtils.showError(context,
                                  title: "Thất bại", message: reason);
                            },
                          ));
                }
              } else {
                // COD
                await bookingRepo.updateBookingStatus(
                    booking.id, BookingStatus.confirmed);
                if (mounted) context.read<ProviderViewModel>().refreshData();
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProviderOrderSuccessScreen(booking: booking),
                    ),
                  );
                }
              }
            }
          },
          onReject: () async {
            bookingStatusSub?.cancel();
            Navigator.pop(ctx);
            _isDialogShowing = false;

            await BookingRepository()
                .updateBookingStatus(booking.id, BookingStatus.cancelled);
            if (mounted) context.read<ProviderViewModel>().refreshData();
          },
        );
      },
    ).then((_) {
      bookingStatusSub?.cancel();
      _isDialogShowing = false;
    });
  }

  /// Hiển thị Dialog hoàn thành công việc
  void _showCompleteJobDialog(BookingModel booking) {
    // Controller nhập liệu
    final TextEditingController _inputController = TextEditingController();
    String label = "Số lượng thực tế";
    String suffix = booking.priceUnit;

    if (booking.priceUnit == 'giờ') {
      label = "Số giờ làm việc";
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hoàn thành công việc"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Đơn giá: ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(booking.totalPrice / (booking.quantity > 0 ? booking.quantity : 1))} / ${booking.priceUnit}"),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: label,
                suffixText: suffix,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_inputController.text);
              if (val == null || val <= 0) {
                DialogUtils.showError(context,
                    title: "Lỗi", message: "Vui lòng nhập số hợp lệ");
                return;
              }
              Navigator.pop(ctx);

              // Gọi ViewModel xử lý logic hoàn thành
              DialogUtils.showLoading(context, message: "Đang cập nhật...");
              context.read<ProviderViewModel>().handleJobCompletion(booking, val, onSuccess: (msg) {
                DialogUtils.hideLoading(
                    context); // Dùng context của Screen vì dialog loading dùng context này
                DialogUtils.showSuccess(context,
                    title: "Thành công", message: msg);
              }, onError: (msg) {
                DialogUtils.hideLoading(context);
                DialogUtils.showError(context, title: "Lỗi", message: msg);
              });
            },
            child: const Text("Xác nhận"),
          )
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProviderViewModel>();

    if (vm.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                DashboardHeader(
                  userName: vm.provider?.name ?? "Thợ",
                  avatarUrl: vm.provider?.avatarUrl,
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: vm.isOnline
                                ? AppColors.greenLight
                                : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.power_settings_new,
                            color: vm.isOnline
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Trạng thái hoạt động",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vm.isOnline
                                    ? "Bạn đang mở nhận việc"
                                    : "Bạn đang tạm tắt nhận việc",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: vm.isOnline,
                          onChanged: (val) {
                            vm.toggleOnlineStatus(val,
                                onError: (msg) => DialogUtils.showError(
                                      context,
                                      title: "Lỗi",
                                      message: msg,
                                    ),
                                onSuccess: (msg) {
                                  if (val) {
                                    DialogUtils.showSuccess(
                                      context,
                                      title: "Online",
                                      message: msg,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Đã tắt hoạt động nhận việc'),
                                      ),
                                    );
                                  }
                                });
                          },
                          activeColor: AppColors.primary,
                          activeTrackColor:
                              AppColors.primary.withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                ),
                DashboardStats(
                  jobsToday: vm.jobsTodayCount,
                  activeJobs: vm.activeJobCount,
                ),
                Consumer<WalletViewModel>(
                  builder: (context, walletVm, child) {
                    return IncomeCard(
                      incomeToday: walletVm.getTodayTotal(),
                      incomeMonth: walletVm.getMonthlyTotal(),
                      onViewDetails: () {
                        // Chuyển sang tab Ví (Index 2)
                        context.read<ProviderViewModel>().setCurrentTabIndex(2);
                      },
                    );
                  }
                ),
                const SizedBox(height: 16),
                UpcomingJobsList(
                  jobs: vm.upcomingJobs,
                  onCompleteJob: _showCompleteJobDialog,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
