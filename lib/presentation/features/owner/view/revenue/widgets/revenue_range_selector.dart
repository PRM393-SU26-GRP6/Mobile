import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/revenue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 3-chip chọn khoảng thời gian xem doanh thu.
class RevenueRangeSelector extends StatelessWidget {
  final RevenueController controller;

  const RevenueRangeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: RevenueRange.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final range = RevenueRange.values[index];
          return Obx(() {
            final isSelected = controller.selectedRange.value == range;
            return GestureDetector(
              onTap: () => controller.changeRange(range),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.inputBorder,
                  ),
                ),
                child: Text(
                  range.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
