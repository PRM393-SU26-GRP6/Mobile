import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';

class BookingVenuePoster extends StatelessWidget {
  const BookingVenuePoster({
    required this.venue,
    this.compact = false,
    super.key,
  });

  final Venue venue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 18 : 22);

    return Container(
      height: compact ? 150 : 210,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [Color(0xFF164C2A), Color(0xFF2AB45A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            if (venue.imageUrls.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  venue.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Positioned.fill(
              child: CustomPaint(painter: PitchLinesPainter(subtle: true)),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Text(
                venue.types.isEmpty
                    ? venue.name
                    : venue.types.map((type) => 'Sân $type').join(' · '),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Positioned(
              right: 18,
              top: 16,
              child: Icon(Icons.sports_soccer, color: Colors.white, size: 42),
            ),
          ],
        ),
      ),
    );
  }
}

class PitchLinesPainter extends CustomPainter {
  const PitchLinesPainter({this.subtle = false});

  final bool subtle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: subtle ? 0.12 : 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = subtle ? 2 : 4;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.72,
      height: size.height * 0.55,
    );
    canvas.drawRect(rect, paint);
    canvas.drawLine(
      Offset(size.width / 2, rect.top),
      Offset(size.width / 2, rect.bottom),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      rect.width * 0.14,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
