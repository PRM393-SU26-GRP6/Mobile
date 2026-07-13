import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueIcon extends StatelessWidget {
  const VenueIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.stadium, color: Colors.white, size: 24),
    );
  }
}

class VenueText extends StatelessWidget {
  final VenueModel venue;

  const VenueText({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          venue.venueName ?? 'San cua toi',
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
                venue.address ?? 'Chua co dia chi',
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
    );
  }
}

class VenueStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const VenueStatItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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

class VenueImagesActionButton extends StatelessWidget {
  final VenueModel venue;

  const VenueImagesActionButton({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Get.toNamed(AppPages.venueImages, arguments: venue),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                'Anh',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
