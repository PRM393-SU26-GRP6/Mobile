import 'package:exe101/presentation/features/customer/shared/customer_constants.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = getBookingStatusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        style.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.color,
        ),
      ),
    );
  }
}
