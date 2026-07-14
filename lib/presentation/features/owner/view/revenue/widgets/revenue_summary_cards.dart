import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/revenue_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Một thẻ hiển thị nhanh 1 con số doanh thu.
class RevenueSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const RevenueSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.decimalPattern('vi_VN');
    final formatted = '${formatter.format(value.round())}đ';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatted,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RevenueSummaryCards extends StatelessWidget {
  final RevenueResponse revenue;

  const RevenueSummaryCards({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RevenueSummaryCard(
            icon: Icons.payments,
            label: 'Tổng doanh thu',
            value: revenue.totalRevenue,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RevenueSummaryCard(
            icon: Icons.account_balance_wallet,
            label: 'Tiền cọc',
            value: revenue.depositRevenue,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RevenueSummaryCard(
            icon: Icons.receipt_long,
            label: 'Thanh toán cuối',
            value: revenue.finalPaymentRevenue,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}
