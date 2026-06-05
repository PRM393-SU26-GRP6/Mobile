import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import 'venue_card.dart';

class VenueListBody extends StatelessWidget {
  const VenueListBody({
    required this.loading,
    required this.venues,
    required this.onSelectVenue,
    super.key,
  });

  final bool loading;
  final List<Venue> venues;
  final ValueChanged<Venue> onSelectVenue;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (venues.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text('Chưa có sân phù hợp')),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      sliver: SliverList.separated(
        itemCount: venues.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final venue = venues[index];
          return VenueCard(venue: venue, onTap: () => onSelectVenue(venue));
        },
      ),
    );
  }
}
