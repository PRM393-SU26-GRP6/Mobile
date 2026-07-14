import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/chat_launcher.dart';
import 'package:flutter/material.dart';

class OwnerBookingActions extends StatelessWidget {
  const OwnerBookingActions({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  });

  final BookingDto booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final isPending = booking.bookingStatus == 'Pending';
    final isAccepted = booking.bookingStatus == 'Accepted';
    if (booking.userId.isEmpty && !isPending && !isAccepted) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.secondary,
      child: Row(
        children: [
          if (booking.userId.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => startChatWithCustomer(booking),
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Nhắn tin'),
            ),
            const SizedBox(width: 12),
          ],
          if (isPending) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Từ chối'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onAccept,
                child: const Text('Chấp nhận'),
              ),
            ),
          ],
          if (isAccepted)
            Expanded(
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Hoàn thành'),
              ),
            ),
        ],
      ),
    );
  }
}
