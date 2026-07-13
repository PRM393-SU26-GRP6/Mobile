import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentHistoryCard extends StatelessWidget {
  final PaymentModel payment;

  const PaymentHistoryCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    final isSuccess = payment.isSuccess;
    final isPending = payment.isPending;
    final isFailed = payment.isFailed;

    Color statusColor;
    String statusText;
    if (isSuccess) {
      statusColor = Colors.green;
      statusText = 'Thành công';
    } else if (isPending) {
      statusColor = Colors.orange;
      statusText = 'Đang xử lý';
    } else if (isFailed) {
      statusColor = Colors.red;
      statusText = 'Thất bại';
    } else {
      statusColor = Colors.grey;
      statusText = payment.paymentStatus.isNotEmpty
          ? payment.paymentStatus
          : 'Không xác định';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payment.transactionCode ?? payment.id.substring(0, 8),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                payment.paymentMethod.value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Text(
                currencyFormatter.format(payment.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                payment.paidAt != null
                    ? DateFormat('HH:mm - dd/MM/yyyy')
                        .format(payment.paidAt!.toLocal())
                    : DateFormat('HH:mm - dd/MM/yyyy')
                        .format(payment.createdAt.toLocal()),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              if (payment.paymentType.isNotEmpty) ...[
                const Spacer(),
                Text(
                  payment.paymentType == 'Deposit'
                      ? 'Đặt cọc'
                      : (payment.paymentType == 'Final'
                          ? 'Thanh toán còn lại'
                          : payment.paymentType),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
