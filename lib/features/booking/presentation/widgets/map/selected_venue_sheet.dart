import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';

class SelectedVenueSheet extends StatelessWidget {
  const SelectedVenueSheet({
    required this.venue,
    required this.liked,
    required this.apiFallback,
    required this.onToggleLike,
    required this.onSelectVenue,
    super.key,
  });

  final Venue venue;
  final bool liked;
  final bool apiFallback;
  final VoidCallback onToggleLike;
  final VoidCallback onSelectVenue;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (apiFallback) ...[
            const Text(
              'Đang dùng dữ liệu mẫu vì chưa kết nối được API.',
              style: TextStyle(
                color: Color(0xFF8A6D1F),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleLike,
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? Colors.redAccent : bookingMuted,
                ),
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
              Text(
                '${money(venue.priceFrom)} - ${money(venue.priceTo)}/giờ',
                style: const TextStyle(
                  color: bookingPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.navigation_outlined),
                  label: const Text('Chỉ đường'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BookingPrimaryButton(
                  label: 'Xem chi tiết',
                  onPressed: onSelectVenue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
