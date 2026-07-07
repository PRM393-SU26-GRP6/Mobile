import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleRow extends StatelessWidget {
  final int index;
  final SlotManagementController controller;

  const ScheduleRow({
    super.key,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dayName = FieldScheduleDto.dayNames[index];
      final schedule = controller.editingSchedules.length > index
          ? controller.editingSchedules[index]
          : null;
      final isActive = schedule?.isActive ?? true;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: index < 6
              ? const Border(
                  bottom: BorderSide(color: AppColors.inputBorder, width: 1),
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    controller.updateEditingSchedule(
                      index,
                      isActive: value,
                      openTime: value ? '06:00' : null,
                      closeTime: value ? '22:00' : null,
                    );
                  },
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              _buildTimeRow(context, schedule),
              const SizedBox(height: 8),
              _buildDurationRow(schedule),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTimeRow(
    BuildContext context,
    FieldScheduleRowDto? schedule,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ScheduleTimeField(
            value: schedule?.openTime ?? '06:00',
            onTap: () async {
              final time = await _showTimePicker(
                Get.context!,
                schedule?.openTime ?? '06:00',
              );
              if (time != null) {
                controller.updateEditingSchedule(index, openTime: time);
              }
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.remove,
            color: AppColors.textSecondary,
            size: 16,
          ),
        ),
        Expanded(
          child: _ScheduleTimeField(
            value: schedule?.closeTime ?? '22:00',
            onTap: () async {
              final time = await _showTimePicker(
                Get.context!,
                schedule?.closeTime ?? '22:00',
              );
              if (time != null) {
                controller.updateEditingSchedule(index, closeTime: time);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationRow(FieldScheduleRowDto? schedule) {
    return Row(
      children: [
        const Text(
          'Slot: ',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        ...[30, 45, 60, 90].map((duration) {
          final isSelected = schedule?.slotDurationMinutes == duration;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                controller.updateEditingSchedule(
                  index,
                  slotDuration: duration,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${duration}m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<String?> _showTimePicker(
    BuildContext context,
    String currentTime,
  ) async {
    final parts = currentTime.split(':');
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
}

class _ScheduleTimeField extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _ScheduleTimeField({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
