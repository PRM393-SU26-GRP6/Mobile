import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/shared/owner_helpers.dart';
import 'package:flutter/material.dart';

class OwnerBookingSummary extends StatelessWidget {
  const OwnerBookingSummary({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = bookingStatusColor(booking.bookingStatus);
    final fieldName = booking.items?.firstOrNull?.fieldName ?? 'Sân';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                booking.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              _dateLabel(booking.startTime),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const _FieldIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fieldName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${formatTimeHM(booking.startTime)} - '
                    '${formatTimeHM(booking.endTime)}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if ((booking.customerName ?? '').isNotEmpty)
                    Text(
                      booking.customerName!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${booking.totalPrice.toStringAsFixed(0)}K',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (booking.depositAmount > 0)
                  Text(
                    '${booking.depositRequirementLabel}: '
                    '${(booking.hasSuccessfulDepositPayment ? booking.paidDepositAmount : booking.depositAmount).toStringAsFixed(0)}K',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
        if ((booking.note ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            booking.note!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _FieldIcon extends StatelessWidget {
  const _FieldIcon();

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.sports_soccer, color: AppColors.primary),
      );
}

String _dateLabel(DateTime value) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(value.year, value.month, value.day);
  if (date == today) return 'Hôm nay';
  if (date == today.add(const Duration(days: 1))) return 'Ngày mai';
  return '${value.day}/${value.month}/${value.year}';
}
