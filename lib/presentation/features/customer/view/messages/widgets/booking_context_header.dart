import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/shared/booking_display.dart';
import 'package:flutter/material.dart';

class BookingContextHeader extends StatelessWidget {
  const BookingContextHeader({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    final statusColor = BookingDisplay.statusColor(booking.bookingStatus);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            BookingDisplay.statusLabel(booking.bookingStatus),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Text(
          BookingDisplay.dateLabel(booking.startTime),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
