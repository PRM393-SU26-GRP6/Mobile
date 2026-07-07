import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:flutter/material.dart';

class ChatDateSeparator extends StatelessWidget {
  final DateTime date;

  const ChatDateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _label(date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  String _label(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return 'Hôm nay';
    if (isSameDay(date, now.subtract(const Duration(days: 1))))
      return 'Hôm qua';
    return '${date.day}/${date.month}/${date.year}';
  }
}
