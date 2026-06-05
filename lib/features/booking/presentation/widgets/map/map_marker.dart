import 'package:flutter/material.dart';

import '../booking_ui.dart';

class MapMarker extends StatelessWidget {
  const MapMarker({
    required this.top,
    required this.left,
    required this.label,
    required this.onTap,
    this.active = false,
    super.key,
  });

  final double top;
  final double left;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: active ? 46 : 38,
          height: active ? 46 : 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bookingPrimary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
