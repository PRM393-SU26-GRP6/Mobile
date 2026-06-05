import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingShell extends StatelessWidget {
  const BookingShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: bookingSurface, child: child);
  }
}
