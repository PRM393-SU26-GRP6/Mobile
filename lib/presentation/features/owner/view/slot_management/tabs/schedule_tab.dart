import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/schedule_row.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_info_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScheduleTab extends StatelessWidget {
  final SlotManagementController controller;
  const ScheduleTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SlotInfoCard(
            message:
                'Thiết lập giờ mở cửa và thời lượng slot cho từng ngày trong tuần.',
          ),
          const SizedBox(height: 16),
          _buildScheduleGrid(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildScheduleGrid() {
    if (controller.editingSchedules.isEmpty) {
      controller.editingSchedules.addAll(
        List.generate(
          7,
          (index) => FieldScheduleRowDto(
            dayOfWeek: index + 1,
            openTime: '06:00',
            closeTime: '22:00',
            slotDurationMinutes: 60,
            isActive: true,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(7, (index) {
          return Obx(() => ScheduleRow(
                index: index,
                controller: controller,
              ));
        }),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: controller.isSavingSchedule.value
                ? null
                : () => controller.saveSchedule(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.green.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: controller.isSavingSchedule.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_outlined, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Lưu lịch sân',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ));
  }
}
