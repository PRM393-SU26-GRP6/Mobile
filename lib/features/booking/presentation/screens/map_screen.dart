import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../widgets/booking_ui.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({required this.onSelectVenue, super.key});

  final VoidCallback onSelectVenue;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _showList = false;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('map'),
      children: [
        Positioned.fill(child: CustomPaint(painter: _MapPainter())),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 16,
          right: 16,
          child: Material(
            elevation: 4,
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: bookingMuted),
                const SizedBox(width: 8),
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Tìm khu vực hoặc tên sân', border: InputBorder.none))),
                IconButton(onPressed: () => setState(() => _showList = !_showList), icon: const Icon(Icons.filter_list)),
              ],
            ),
          ),
        ),
        const _MapMarker(top: 150, left: 80, label: '12'),
        const _MapMarker(top: 240, left: 235, label: '⚽', active: true),
        const _MapMarker(top: 345, left: 145, label: '⚽'),
        const _MapMarker(top: 120, left: 285, label: '5'),
        Positioned(
          right: 16,
          bottom: 220,
          child: FloatingActionButton.small(
            heroTag: 'location',
            onPressed: () {},
            backgroundColor: Colors.white,
            foregroundColor: bookingPrimary,
            child: const Icon(Icons.navigation_outlined),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _showList
              ? _NearbyList(onSelectVenue: widget.onSelectVenue)
              : _SelectedVenueSheet(
                  liked: _liked,
                  onToggleLike: () => setState(() => _liked = !_liked),
                  onSelectVenue: widget.onSelectVenue,
                ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.top, required this.left, required this.label, this.active = false});

  final double top;
  final double left;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
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
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SelectedVenueSheet extends StatelessWidget {
  const _SelectedVenueSheet({
    required this.liked,
    required this.onToggleLike,
    required this.onSelectVenue,
  });

  final bool liked;
  final VoidCallback onToggleLike;
  final VoidCallback onSelectVenue;

  @override
  Widget build(BuildContext context) {
    final venue = bookingVenues.first;
    return BookingCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(venue.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
              IconButton(
                onPressed: onToggleLike,
                icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.redAccent : bookingMuted),
              ),
            ],
          ),
          BookingInfoLine(icon: Icons.place_outlined, text: venue.address),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text(' ${venue.rating} (${venue.reviewCount})'),
              const Spacer(),
              Text('${money(venue.priceFrom)} - ${money(venue.priceTo)}/giờ', style: const TextStyle(color: bookingPrimary, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.navigation_outlined), label: const Text('Chỉ đường'))),
              const SizedBox(width: 10),
              Expanded(child: BookingPrimaryButton(label: 'Xem chi tiết', onPressed: onSelectVenue)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NearbyList extends StatelessWidget {
  const _NearbyList({required this.onSelectVenue});

  final VoidCallback onSelectVenue;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BookingSectionTitle(title: 'Sân gần bạn'),
          ...bookingVenues.take(2).map(
                (venue) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(backgroundColor: bookingMint, child: Text('⚽')),
                  title: Text(venue.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${venue.address}\n${money(venue.priceFrom)} - ${money(venue.priceTo)}/giờ'),
                  isThreeLine: true,
                  onTap: onSelectVenue,
                ),
              ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFE8F5EC), BlendMode.src);
    final grid = Paint()
      ..color = bookingLine.withOpacity(0.35)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final road = Paint()
      ..color = bookingMuted.withOpacity(0.28)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    final path = Path()
      ..moveTo(-20, size.height * 0.34)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.28, size.width + 20, size.height * 0.36);
    canvas.drawPath(path, road);
    final path2 = Path()
      ..moveTo(size.width * 0.35, -20)
      ..quadraticBezierTo(size.width * 0.42, size.height * 0.5, size.width * 0.38, size.height + 20);
    canvas.drawPath(path2, road..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
