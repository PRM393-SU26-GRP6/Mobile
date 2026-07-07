import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialog chỉnh giá + trạng thái 1 slot.
/// Dùng StatefulBuilder để giữ selectedStatus reactive trong dialog.
Future<void> showSlotEditDialog(
  BuildContext context,
  TimeSlotDto slot,
) async {
  final priceController = TextEditingController(text: slot.price.toString());

  final availableOptions = <String, String>{
    'Available': 'Trống (mở bán)',
    'Locked': 'Khoá (ẩn khỏi khách)',
  };
  String selectedStatus = slot.slotStatus ?? 'Available';
  if (!availableOptions.containsKey(selectedStatus)) {
    selectedStatus = 'Available';
  }

  final result = await Get.dialog<_SlotEditResult>(
    StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.edit_calendar, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sửa slot ${slot.timeRange}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Ngày', value: slot.selectedDate),
                const SizedBox(height: 14),
                const Text(
                  'Giá slot (VNĐ)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập giá',
                    prefixIcon: const Icon(Icons.attach_money,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.secondary,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.inputBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Trạng thái',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ...availableOptions.entries.map((entry) {
                  final isSel = entry.key == selectedStatus;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedStatus = entry.key;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSel ? AppColors.primary : AppColors.inputBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSel
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isSel
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    isSel ? FontWeight.w600 : FontWeight.w400,
                                color: isSel
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                final newPrice = double.tryParse(priceController.text.trim());
                if (newPrice == null || newPrice <= 0) {
                  Get.snackbar('Lỗi', 'Giá phải là số dương',
                      snackPosition: SnackPosition.TOP);
                  return;
                }
                Navigator.of(ctx).pop(
                  _SlotEditResult(price: newPrice, status: selectedStatus),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    ),
  );

  if (result == null) return;
  if (!Get.isRegistered<SlotActionsController>()) return;

  final actions = Get.find<SlotActionsController>();
  final ok = await actions.updateSlot(
    slotId: slot.slotId,
    price: result.price,
    status: result.status,
  );
  if (ok && Get.isRegistered<SlotManagementController>()) {
    await Get.find<SlotManagementController>().loadSlots();
  }
}

class _SlotEditResult {
  final double? price;
  final String? status;
  _SlotEditResult({required this.price, required this.status});
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
