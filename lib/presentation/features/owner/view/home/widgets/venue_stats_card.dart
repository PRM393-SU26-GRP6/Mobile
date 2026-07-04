import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stadium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.venueName ?? 'Sân của tôi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue.address ?? 'Chưa có địa chỉ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.sports_soccer,
                label: 'Sân con',
                value: '${venue.fields?.length ?? 0}',
              ),
              _buildStatItem(
                icon: Icons.star,
                label: 'Đánh giá',
                value: venue.averageRating?.toStringAsFixed(1) ?? '-',
              ),
              _buildStatItem(
                icon: Icons.attach_money,
                label: 'Giá từ',
                value: venue.minPrice != null
                    ? '${venue.minPrice!.toStringAsFixed(0)}K'
                    : '-',
              ),
              _buildStatItem(
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
