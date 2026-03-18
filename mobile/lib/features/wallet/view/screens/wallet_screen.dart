import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/viewmodel/auth_viewmodel.dart';
import '../../viewmodel/wallet_viewmodel.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/income_chart_section.dart';
import '../widgets/transaction_history_list.dart';
import '../widgets/withdraw_dialog.dart';
import 'topup_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = Provider.of<AuthViewModel>(context, listen: false);
      final walletVm = Provider.of<WalletViewModel>(context, listen: false);
      if (authVm.currentUser != null) {
        walletVm.initWallet(authVm.currentUser!.uid);
        walletVm.listenToWallet(authVm.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Thu nhập của Thợ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.wallet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.wallet == null) {
            return Center(child: Text(viewModel.error!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authVm = Provider.of<AuthViewModel>(context, listen: false);
              if (authVm.currentUser != null) {
                await viewModel.initWallet(authVm.currentUser!.uid);
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wallet Balance Card
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: WalletBalanceCard(
                      wallet: viewModel.wallet,
                      onWithdraw: () {
                        showDialog(
                          context: context,
                          builder: (context) => WithdrawDialog(
                            currentBalance: viewModel.wallet?.balance ?? 0.0,
                            onConfirm: (amount, bankInfo) async {
                              final authVm = Provider.of<AuthViewModel>(context, listen: false);
                              try {
                                await viewModel.withdrawMoney(
                                  authVm.currentUser!.uid,
                                  amount,
                                  bankInfo,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Yêu cầu rút tiền thành công!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      onTopUp: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TopUpScreen()),
                        );
                      },
                    ),
                  ),

                  // Income Chart Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IncomeChartSection(
                      weeklyChartData: viewModel.getWeeklyChartData(),
                      weeklyTotal: viewModel.getWeeklyTotal(),
                      monthlyTotal: viewModel.getMonthlyTotal(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Transaction History
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lịch sử giao dịch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TransactionHistoryList(
                          transactions: viewModel.transactions,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
