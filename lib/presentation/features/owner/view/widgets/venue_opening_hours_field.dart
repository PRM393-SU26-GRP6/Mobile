import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class VenueOpeningHoursField extends StatelessWidget {
  const VenueOpeningHoursField({
    required this.openingController,
    required this.closingController,
    super.key,
  });

  final TextEditingController openingController;
  final TextEditingController closingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Khung giờ hoạt động',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimePickerField(
                  controller: openingController,
                  label: 'Mở cửa',
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward),
              ),
              Expanded(
                child: _TimePickerField(
                  controller: closingController,
                  label: 'Đóng cửa',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _pickTime(context),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            const Icon(Icons.schedule, size: 16),
            const SizedBox(width: 8),
            Text(
              controller.text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final parts = controller.text.split(':');
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 6,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      ),
    );
    if (time == null) return;
    controller.text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
