import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingCartIcon extends StatelessWidget {
  const BookingCartIcon({
    required this.count,
    required this.onTap,
    this.light = false,
    super.key,
  });

  final int count;
  final VoidCallback onTap;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          color: light ? Colors.white : bookingText,
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 2,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Colors.amber,
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  color: bookingText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
