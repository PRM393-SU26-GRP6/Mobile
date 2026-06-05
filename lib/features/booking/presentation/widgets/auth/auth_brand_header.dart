import 'package:flutter/material.dart';

import '../booking_ui.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: bookingPrimary,
          foregroundColor: Colors.white,
          child: Text('⚽', style: TextStyle(fontSize: 26)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PitchBook',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: bookingText,
                ),
              ),
              Text(
                'Đặt sân bóng nhanh trong vài chạm',
                style: TextStyle(color: bookingMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
