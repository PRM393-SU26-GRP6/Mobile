import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueTopNav extends StatelessWidget {
  final VenueDetailController controller;
  const VenueTopNav({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final venueName = controller.venue.value?.venueName ?? '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              venueName,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
