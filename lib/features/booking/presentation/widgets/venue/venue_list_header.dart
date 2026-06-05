import 'package:flutter/material.dart';

import '../booking_ui.dart';

class VenueListHeader extends StatelessWidget {
  const VenueListHeader({
    required this.cartCount,
    required this.onOpenCart,
    required this.onOpenNotifications,
    super.key,
  });

  final int cartCount;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        MediaQuery.paddingOf(context).top + 18,
        18,
        24,
      ),
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
                child: Text(
                  'PitchBook',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenNotifications,
                color: Colors.white,
                icon: const Icon(Icons.notifications_none),
              ),
              BookingCartIcon(count: cartCount, onTap: onOpenCart, light: true),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tìm sân gần bạn',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
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
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
