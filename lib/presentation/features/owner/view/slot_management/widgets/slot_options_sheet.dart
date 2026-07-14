import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bottom sheet tuỳ chọn slot: mở / khoá / xoá.
Future<void> showSlotOptionsSheet(
  BuildContext context,
  TimeSlotDto slot,
) async {
  await Get.bottomSheet<void>(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Khung giờ ${slot.timeRange}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${slot.price.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            SlotOptionTile(
              icon: slot.isAvailable ? Icons.lock : Icons.lock_open,
              label: slot.isAvailable ? 'Khóa khung giờ' : 'Mở khung giờ',
              color: slot.isAvailable ? AppColors.textSecondary : Colors.green,
              onTap: () async {
                Get.back();
                final actions = Get.find<SlotActionsController>();
                final ok = await actions.toggleSlotStatus(
                  slot.slotId,
                  !slot.isAvailable,
                );
                if (ok && Get.isRegistered<SlotManagementController>()) {
                  await Get.find<SlotManagementController>().loadSlots();
                }
              },
            ),
            SlotOptionTile(
              icon: Icons.delete_outline,
              label: 'Xóa khung giờ',
              color: Colors.red,
              destructive: true,
              onTap: () async {
                Get.back();
                final ok = await showConfirmDialog(
                  title: 'Xóa khung giờ',
                  message:
                      'Bạn có chắc muốn xóa khung giờ ${slot.timeRange} ngày ${slot.selectedDate}?',
                  confirmText: 'Xoá',
                  confirmColor: Colors.red,
                );
                if (!ok) return;
                final actions = Get.find<SlotActionsController>();
                final deleted = await actions.deleteSlot(slot.slotId);
                if (deleted && Get.isRegistered<SlotManagementController>()) {
                  await Get.find<SlotManagementController>().loadSlots();
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
