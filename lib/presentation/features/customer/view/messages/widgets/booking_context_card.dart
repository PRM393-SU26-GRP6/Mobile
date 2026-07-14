import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/booking_context_details.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/booking_context_header.dart';
import 'package:flutter/material.dart';

class BookingContextCard extends StatelessWidget {
  const BookingContextCard({
    super.key,
    required this.booking,
    this.onViewDetails,
  });

  final BookingDto booking;
  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingContextHeader(booking: booking),
          const SizedBox(height: 12),
          BookingContextDetails(booking: booking),
          if ((booking.note ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            BookingContextNote(note: booking.note!.trim()),
          ],
          if (onViewDetails != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Xem đơn'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
