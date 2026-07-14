import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/owner/view/home/widgets/venue_stats_card_parts.dart';
import 'package:flutter/material.dart';

class VenueStatsCard extends StatelessWidget {
  final VenueModel venue;

  const VenueStatsCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const VenueIcon(),
              const SizedBox(width: 12),
              Expanded(child: VenueText(venue: venue)),
              VenueImagesActionButton(venue: venue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              VenueStatItem(
                icon: Icons.sports_soccer,
                label: 'Sân con',
                value: '${venue.fields?.length ?? 0}',
              ),
              VenueStatItem(
                icon: Icons.star,
                label: 'Đánh giá',
                value: venue.averageRating?.toStringAsFixed(1) ?? '-',
              ),
              VenueStatItem(
                icon: Icons.reviews_outlined,
                label: 'Lượt review',
                value: '${venue.totalReviews ?? 0}',
              ),
              VenueStatItem(
                icon: Icons.check_circle,
                label: 'Trạng thái',
                value: venue.isActive == true ? 'Mở' : 'Đóng',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
