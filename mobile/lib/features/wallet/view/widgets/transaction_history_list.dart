import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionHistoryList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Chưa có giao dịch nào',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: Color(0xFFF1F5F9),
      ),
      itemBuilder: (context, index) {
        final trans = transactions[index];
        return _buildTransactionItem(trans);
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel trans) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isNegative = trans.amount < 0;

    IconData iconData;
    switch (trans.type) {
      case TransactionType.income:
        iconData = Icons.construction;
        break;
      case TransactionType.commission:
        iconData = Icons.account_balance_wallet;
        break;
      case TransactionType.withdrawal:
        iconData = Icons.outbox;
        break;
      case TransactionType.topup:
        iconData = Icons.add_circle_outline;
        break;
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: Colors.grey[500],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trans.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(trans.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isNegative ? '' : '+'}${currencyFormat.format(trans.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isNegative ? Colors.red[600] : Colors.green[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
