import 'package:flutter/material.dart';

class BookingConfirmError extends StatelessWidget {
  const BookingConfirmError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
