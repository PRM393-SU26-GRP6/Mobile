import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

/// Date picker dạng ô chạm để mở showDatePicker.
class SlotDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const SlotDatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date != null) onChanged(date);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null ? formatDateVN(value!) : label,
                style: TextStyle(
                  fontSize: 14,
                  color: value != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
