import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_edit_dialog.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_options_sheet.dart';
import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final TimeSlotDto slot;
  const SlotCard({super.key, required this.slot});

  Future<void> _showEditDialog(BuildContext context) async {
    await showSlotEditDialog(context, slot);
  }

  Future<void> _showOptionsSheet(BuildContext context) async {
    await showSlotOptionsSheet(context, slot);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final statusLabel = _statusLabel();

    return GestureDetector(
      onTap: () => _showEditDialog(context),
      onLongPress: () => _showOptionsSheet(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _statusIcon(),
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.timeRange,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot.selectedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${slot.price.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Icon(
                  slot.isAvailable ? Icons.lock_open : Icons.lock,
                  color: slot.isAvailable ? Colors.green : Colors.grey,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  slot.isAvailable ? 'Mở' : 'Khóa',
                  style: TextStyle(
                    fontSize: 11,
                    color: slot.isAvailable ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textSecondary, size: 20),
              onPressed: () => _showOptionsSheet(context),
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
