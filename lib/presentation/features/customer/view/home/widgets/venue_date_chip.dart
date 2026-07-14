import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:flutter/material.dart';

class VenueDateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const VenueDateChip({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  static const _dayNames = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 64,
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : isToday
                    ? AppColors.accent
                    : AppColors.inputBorder,
            width: isSelected || isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _dayNames[date.weekday - 1],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'T${date.month}',
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
