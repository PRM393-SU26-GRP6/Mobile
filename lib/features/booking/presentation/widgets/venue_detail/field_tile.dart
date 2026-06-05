import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';

class FieldTile extends StatelessWidget {
  const FieldTile({
    required this.field,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final FieldInfo field;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: selected ? bookingPrimary : bookingLine,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: selected ? bookingPrimary : bookingMint,
            foregroundColor: selected ? Colors.white : bookingPrimary,
            child: Text(field.type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              field.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            money(field.price),
            style: const TextStyle(
              color: bookingPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
