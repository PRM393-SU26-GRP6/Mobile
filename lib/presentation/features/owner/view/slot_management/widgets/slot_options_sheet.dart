import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_dialogs.dart';
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
                      'Slot ${slot.timeRange}',
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
            _SheetTile(
              icon: slot.isAvailable ? Icons.lock : Icons.lock_open,
              label: slot.isAvailable ? 'Khoá slot' : 'Mở khoá slot',
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
            _SheetTile(
              icon: Icons.delete_outline,
              label: 'Xoá slot',
              color: Colors.red,
              destructive: true,
              onTap: () async {
                Get.back();
                final ok = await showConfirmDialog(
                  title: 'Xoá slot',
                  message:
                      'Bạn có chắc muốn xoá slot ${slot.timeRange} ngày ${slot.selectedDate}?',
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

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool destructive;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: destructive ? Colors.red : AppColors.textPrimary,
                  fontWeight: destructive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
