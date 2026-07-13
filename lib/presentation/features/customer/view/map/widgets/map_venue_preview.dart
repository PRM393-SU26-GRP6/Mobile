import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapVenuePreview extends StatelessWidget {
  const MapVenuePreview({super.key, required this.venue});

  final VenueModel venue;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        venue.images?.isNotEmpty == true ? venue.images!.first : null;
    return Container(
      height: 104,
      constraints: const BoxConstraints(maxWidth: 520),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 84,
              height: 84,
              child: imageUrl == null
                  ? const ColoredBox(
                      color: AppColors.secondary,
                      child: Icon(Icons.sports_soccer,
                          color: AppColors.primary, size: 34),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AppColors.secondary,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  venue.venueName ?? 'Sân bóng',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  venue.address ?? 'Chưa có địa chỉ',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Xem sân',
            onPressed: () =>
                Get.toNamed(AppPages.venueDetail, arguments: venue),
            icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
