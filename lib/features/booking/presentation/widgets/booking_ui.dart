import 'package:flutter/material.dart';

import '../../domain/booking_models.dart';

const bookingPrimary = Color(0xFF1A8C3E);
const bookingPrimaryDark = Color(0xFF0D4A1E);
const bookingPrimaryLight = Color(0xFF25C05A);
const bookingSurface = Color(0xFFF2FAF4);
const bookingMint = Color(0xFFE3F2E6);
const bookingLine = Color(0xFFB0CEB5);
const bookingText = Color(0xFF0B1F0E);
const bookingMuted = Color(0xFF3D5C42);

String money(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromEnd = raw.length - i;
    buffer.write(raw[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }
  return '${buffer}đ';
}

class BookingShell extends StatelessWidget {
  const BookingShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: bookingSurface, child: child);
  }
}

class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.borderColor = bookingLine,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: card);
  }
}

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
      padding: EdgeInsets.fromLTRB(8, MediaQuery.paddingOf(context).top + 4, 12, 8),
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
              style: const TextStyle(color: bookingPrimary, fontSize: 19, fontWeight: FontWeight.w900),
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

class BookingPrimaryButton extends StatelessWidget {
  const BookingPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ],
          );

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: bookingPrimary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: child,
    );
  }
}

class BookingBottomAction extends StatelessWidget {
  const BookingBottomAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: bookingLine)),
      ),
      child: BookingPrimaryButton(
        label: label,
        icon: icon,
        onPressed: enabled ? onPressed : () {},
      ),
    );
  }
}

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(color: bookingText, fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class BookingSoftChip extends StatelessWidget {
  const BookingSoftChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: bookingMint,
      side: const BorderSide(color: bookingLine),
      labelStyle: const TextStyle(color: bookingMuted, fontWeight: FontWeight.w700),
    );
  }
}

class BookingAmountLine extends StatelessWidget {
  const BookingAmountLine({
    required this.label,
    required this.value,
    this.highlight = false,
    super.key,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: highlight ? bookingText : bookingMuted,
              fontWeight: highlight ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? bookingPrimary : bookingText,
            fontWeight: FontWeight.w900,
            fontSize: highlight ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

class BookingNotice extends StatelessWidget {
  const BookingNotice({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bookingMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bookingLine),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: bookingPrimary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: bookingMuted, height: 1.35))),
        ],
      ),
    );
  }
}

class BookingEmptyState extends StatelessWidget {
  const BookingEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: bookingMint,
              foregroundColor: bookingPrimary,
              child: Icon(icon, size: 34),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: bookingMuted)),
          ],
        ),
      ),
    );
  }
}

class BookingInfoLine extends StatelessWidget {
  const BookingInfoLine({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: bookingMuted),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(color: bookingMuted))),
      ],
    );
  }
}

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
                style: const TextStyle(fontSize: 11, color: bookingText, fontWeight: FontWeight.w900),
              ),
            ),
          ),
      ],
    );
  }
}

class BookingVenuePoster extends StatelessWidget {
  const BookingVenuePoster({required this.venue, this.compact = false, super.key});

  final Venue venue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 150 : 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? 18 : 22),
        gradient: const LinearGradient(
          colors: [Color(0xFF164C2A), Color(0xFF2AB45A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: PitchLinesPainter(subtle: true))),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              venue.types.map((type) => 'Sân $type').join(' · '),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const Positioned(right: 18, top: 16, child: Text('⚽', style: TextStyle(fontSize: 42))),
        ],
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
      ..color = Colors.white.withOpacity(subtle ? 0.12 : 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = subtle ? 2 : 4;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.72,
      height: size.height * 0.55,
    );
    canvas.drawRect(rect, paint);
    canvas.drawLine(Offset(size.width / 2, rect.top), Offset(size.width / 2, rect.bottom), paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), rect.width * 0.14, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
