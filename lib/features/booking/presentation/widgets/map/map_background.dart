import 'package:flutter/material.dart';

import '../booking_ui.dart';

class MapBackground extends StatelessWidget {
  const MapBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: MapBackgroundPainter());
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE8F5EC), BlendMode.src);
    final grid = Paint()
      ..color = bookingLine.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = bookingMuted.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    final path = Path()
      ..moveTo(-20, size.height * 0.34)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.28,
        size.width + 20,
        size.height * 0.36,
      );
    canvas.drawPath(path, road);
    final path2 = Path()
      ..moveTo(size.width * 0.35, -20)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.5,
        size.width * 0.38,
        size.height + 20,
      );
    canvas.drawPath(path2, road..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
