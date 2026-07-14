import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:flutter/material.dart';

class VenueAmenitiesSection extends StatelessWidget {
  const VenueAmenitiesSection({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    final amenities = controller.venue.value?.amenities ?? [];
    if (amenities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiện ích',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: amenities
                .map(
                  (amenity) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          amenity.amenityName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.inputBorder, height: 1),
        ],
      ),
    );
  }
}
