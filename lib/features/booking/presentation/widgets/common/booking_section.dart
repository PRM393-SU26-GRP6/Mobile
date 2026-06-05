import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: bookingText,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class BookingSoftChip extends StatelessWidget {
  const BookingSoftChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: bookingMint,
      side: const BorderSide(color: bookingLine),
      labelStyle: const TextStyle(
        color: bookingMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class BookingAmountLine extends StatelessWidget {
  const BookingAmountLine({
    required this.label,
    required this.value,
    this.highlight = false,
    super.key,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlight ? bookingText : bookingMuted,
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? bookingPrimary : bookingText,
            fontWeight: FontWeight.w900,
            fontSize: highlight ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
