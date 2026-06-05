import 'package:flutter/material.dart';

import 'booking_tokens.dart';

class BookingTopBar extends StatelessWidget {
  const BookingTopBar({
    required this.title,
    this.onBack,
    this.trailing,
    this.actionLabel,
    super.key,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.paddingOf(context).top + 4,
        12,
        8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: bookingLine)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: bookingPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: () {}, child: Text(actionLabel!))
          else
            trailing ?? const SizedBox(width: 48),
        ],
      ),
    );
  }
}
