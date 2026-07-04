import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Picker giờ HH:mm chỉ hiển thị, tap để mở showTimePicker.
class SlotTimePickerField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SlotTimePickerField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Future<String?> _showTimePicker(BuildContext context) async {
    final parts = value.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selectedTime != null) {
      return '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  Future<void> _pick(BuildContext context) async {
    final time = await _showTimePicker(context);
    if (time != null) onChanged(time);
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
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
