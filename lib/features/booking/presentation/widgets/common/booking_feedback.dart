import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingNotice extends StatelessWidget {
  const BookingNotice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bookingMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bookingLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: bookingPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: bookingMuted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: bookingMint,
              foregroundColor: bookingPrimary,
              child: Icon(icon, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: bookingMuted),
            ),
          ],
        ),
      ),
    );
  }
}
