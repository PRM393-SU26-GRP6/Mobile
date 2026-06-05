import 'package:flutter/material.dart';

import '../booking_ui.dart';

class VenueDateChip extends StatelessWidget {
  const VenueDateChip({
    required this.label,
    required this.date,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String date;
  final String value;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = date == value;
    return InkWell(
      onTap: () => onTap(date),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? bookingPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? bookingPrimary : bookingLine),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : bookingText,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            Text(
              date.substring(5).replaceAll('-', '/'),
              style: TextStyle(
                color: selected ? Colors.white70 : bookingMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
