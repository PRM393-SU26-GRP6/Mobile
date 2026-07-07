import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/revenue_model.dart';
import 'package:exe101/presentation/features/owner/view/revenue/widgets/simple_bar_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Card vẽ biểu đồ doanh thu theo nhóm (ngày/tuần/tháng).
class RevenueChartCard extends StatelessWidget {
  final List<RevenuePoint> groups;

  const RevenueChartCard({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Chưa có dữ liệu doanh thu trong khoảng này',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    final values = groups.map((e) => e.revenue).toList();
    final labels = groups.map(_formatLabel).toList();

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'Biểu đồ doanh thu',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: SimpleBarChart(values: values, labels: labels),
          ),
        ],
      ),
    );
  }

  String _formatLabel(RevenuePoint point) {
    final dt = point.date;
    if (dt != null) return DateFormat('dd/MM').format(dt);
    return point.label ?? '';
  }
}
