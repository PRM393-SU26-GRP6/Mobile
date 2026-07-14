import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter/material.dart';

class SlotStatusIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const SlotStatusIcon({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class SlotInfo extends StatelessWidget {
  final TimeSlotDto slot;
  final Color statusColor;
  final String statusLabel;

  const SlotInfo({
    super.key,
    required this.slot,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _StatusChip(label: statusLabel, color: statusColor),
            const SizedBox(width: 10),
            Text(
              '${slot.price.toStringAsFixed(0)}d',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SlotLockState extends StatelessWidget {
  final TimeSlotDto slot;

  const SlotLockState({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final color = slot.isAvailable ? Colors.green : Colors.grey;
    return Column(
      children: [
        Icon(
          slot.isAvailable ? Icons.lock_open : Icons.lock,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          slot.isAvailable ? 'Mở' : 'Khóa',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
