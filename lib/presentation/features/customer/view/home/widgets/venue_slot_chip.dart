import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter/material.dart';

class VenueSlotChip extends StatelessWidget {
  final TimeSlotDto slot;
  final bool isSelected;
  final VoidCallback onTap;

  const VenueSlotChip({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;

    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent
              : available
                  ? AppColors.secondary
                  : Colors.grey.shade800.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : available
                    ? AppColors.inputBorder
                    : Colors.grey.shade700,
          ),
        ),
        child: Column(
          children: [
            Text(
              slot.timeRange,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : available
                        ? AppColors.textPrimary
                        : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${slot.price.toStringAsFixed(0)}đ',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : available
                        ? AppColors.textSecondary
                        : Colors.grey.shade700,
              ),
            ),
            if (!available)
              Text(
                'Đã đặt',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
