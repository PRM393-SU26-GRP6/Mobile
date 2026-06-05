import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingInfoLine extends StatelessWidget {
  const BookingInfoLine({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: bookingMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text, style: const TextStyle(color: bookingMuted)),
        ),
      ],
    );
  }
}
