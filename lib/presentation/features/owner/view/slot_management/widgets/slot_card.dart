import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_card_parts.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_edit_dialog.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_options_sheet.dart';
import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final TimeSlotDto slot;
  final bool isSelected;
  final bool selectionMode;
  final ValueChanged<bool>? onSelectedChanged;

  const SlotCard({
    super.key,
    required this.slot,
    this.isSelected = false,
    this.selectionMode = false,
    this.onSelectedChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return GestureDetector(
      onTap: selectionMode
          ? () => onSelectedChanged?.call(!isSelected)
          : () => showSlotEditDialog(context, slot),
      onLongPress: () => onSelectedChanged?.call(!isSelected),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SlotStatusIcon(color: statusColor, icon: _statusIcon()),
            const SizedBox(width: 14),
            Expanded(
              child: SlotInfo(
                slot: slot,
                statusColor: statusColor,
                statusLabel: _statusLabel(),
              ),
            ),
            SlotLockState(slot: slot),
            const SizedBox(width: 8),
            if (selectionMode)
              Checkbox(
                value: isSelected,
                activeColor: AppColors.primary,
                onChanged: (value) => onSelectedChanged?.call(value ?? false),
              )
            else
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => showSlotOptionsSheet(context, slot),
                tooltip: 'Tùy chọn',
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor() {
    if (slot.isBooked) return Colors.orange;
    if (slot.isLocked) return Colors.grey;
    if (slot.isPending) return Colors.blue;
    return Colors.green;
  }

  String _statusLabel() {
    if (slot.isBooked) return 'Đã đặt';
    if (slot.isLocked) return 'Khóa';
    if (slot.isPending) return 'Chờ xác nhận';
    return 'Trống';
  }

  IconData _statusIcon() {
    if (slot.isBooked) return Icons.event_busy;
    if (slot.isLocked) return Icons.lock;
    if (slot.isPending) return Icons.pending;
    return Icons.event_available;
  }
}
