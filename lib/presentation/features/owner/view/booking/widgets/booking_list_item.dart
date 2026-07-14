import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/owner_booking_actions.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/owner_booking_summary.dart';
import 'package:flutter/material.dart';

class BookingListItem extends StatelessWidget {
  const BookingListItem({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
    required this.onTap,
  });

  final BookingDto booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.inputBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: OwnerBookingSummary(booking: booking),
            ),
            OwnerBookingActions(
              booking: booking,
              onAccept: onAccept,
              onReject: onReject,
              onComplete: onComplete,
            ),
          ],
        ),
      ),
    );
  }
}
