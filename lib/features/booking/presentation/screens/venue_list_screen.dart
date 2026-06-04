import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class VenueListScreen extends StatefulWidget {
  const VenueListScreen({
    required this.cartCount,
    required this.onOpenCart,
    required this.onOpenNotifications,
    required this.onSelectVenue,
    super.key,
  });

  final int cartCount;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenNotifications;
  final ValueChanged<Venue> onSelectVenue;

  @override
  State<VenueListScreen> createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  String _query = '';
  String _type = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final venues = bookingVenues.where((venue) {
      final query = _query.toLowerCase();
      final matchQuery = query.isEmpty ||
          venue.name.toLowerCase().contains(query) ||
          venue.address.toLowerCase().contains(query);
      final matchType = _type == 'Tất cả' || venue.types.contains(_type);
      return matchQuery && matchType;
    }).toList();

    return BookingShell(
      key: const ValueKey('venues'),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HeroHeader(
              cartCount: widget.cartCount,
              onOpenCart: widget.onOpenCart,
              onOpenNotifications: widget.onOpenNotifications,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'Tìm tên sân hoặc khu vực',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: bookingLine),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Tất cả', '5', '7', '11'].map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(type == 'Tất cả' ? type : 'Sân $type'),
                            selected: _type == type,
                            onSelected: (_) => setState(() => _type = type),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            sliver: SliverList.separated(
              itemCount: venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final venue = venues[index];
                return _VenueCard(venue: venue, onTap: () => widget.onSelectVenue(venue));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.cartCount,
    required this.onOpenCart,
    required this.onOpenNotifications,
  });

  final int cartCount;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, MediaQuery.paddingOf(context).top + 18, 18, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [bookingPrimaryDark, bookingPrimary]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('PitchBook', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
              ),
              IconButton(onPressed: onOpenNotifications, color: Colors.white, icon: const Icon(Icons.notifications_none)),
              BookingCartIcon(count: cartCount, onTap: onOpenCart, light: true),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Tìm sân gần bạn', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 18),
          const Row(
            children: [
              _HeroMetric(value: '24', label: 'sân gần bạn'),
              SizedBox(width: 10),
              _HeroMetric(value: '9', label: 'slot trống'),
              SizedBox(width: 10),
              _HeroMetric(value: '20%', label: 'ưu đãi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  const _VenueCard({required this.venue, required this.onTap});

  final Venue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingVenuePoster(venue: venue, compact: true),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(venue.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                    const Icon(Icons.favorite_border, color: bookingMuted),
                  ],
                ),
                const SizedBox(height: 8),
                BookingInfoLine(icon: Icons.place_outlined, text: venue.address),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${venue.rating} (${venue.reviewCount})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Text('${money(venue.priceFrom)} - ${money(venue.priceTo)}/giờ', style: const TextStyle(color: bookingPrimary, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
