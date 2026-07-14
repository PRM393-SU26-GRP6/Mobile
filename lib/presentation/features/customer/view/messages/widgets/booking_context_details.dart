import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/shared/booking_display.dart';
import 'package:flutter/material.dart';

class BookingContextDetails extends StatelessWidget {
  const BookingContextDetails({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.sports_soccer, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                BookingDisplay.fieldName(booking),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${BookingDisplay.time(booking.startTime)} - '
                '${BookingDisplay.time(booking.endTime)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              BookingDisplay.compactMoney(booking.totalPrice),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (booking.depositAmount > 0)
              Text(
                'Đặt cọc: ${BookingDisplay.compactMoney(booking.depositAmount)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class BookingContextNote extends StatelessWidget {
  const BookingContextNote({super.key, required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        note,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}
