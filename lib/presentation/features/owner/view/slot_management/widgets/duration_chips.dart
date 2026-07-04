import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Hiển thị các chip chọn thời lượng slot (30/60/90/120 phút).
class DurationChips extends StatelessWidget {
  final List<int> availableDurations;
  final int selectedDuration;
  final ValueChanged<int> onChanged;

  const DurationChips({
    super.key,
    required this.availableDurations,
    required this.selectedDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: availableDurations.map((duration) {
        final isSelected = selectedDuration == duration;
        return GestureDetector(
          onTap: () => onChanged(duration),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            ),
            child: Text(
              '$duration phút',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
