import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';

class NearbyList extends StatelessWidget {
  const NearbyList({
    required this.venues,
    required this.onSelectVenue,
    super.key,
  });

  final List<Venue> venues;
  final ValueChanged<Venue> onSelectVenue;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BookingSectionTitle(title: 'Sân gần bạn'),
          ...venues
              .take(3)
              .map(
                (venue) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: bookingMint,
                    child: Icon(Icons.sports_soccer, color: bookingPrimary),
                  ),
                  title: Text(
                    venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${venue.address}\n${money(venue.priceFrom)} - ${money(venue.priceTo)}/giờ',
                  ),
                  isThreeLine: true,
                  onTap: () => onSelectVenue(venue),
                ),
              ),
        ],
      ),
    );
  }
}
