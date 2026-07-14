import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_amenities_section.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_booking_bar.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_field_section.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_image_header.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_info_section.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_reviews_section.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_time_slots_section.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_top_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueDetailController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Obx(() {
        if (controller.isLoadingVenue.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        if (controller.venue.value == null) {
          return _VenueError(message: controller.error.value);
        }

        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VenueImageHeader(controller: controller),
                  VenueInfoSection(controller: controller),
                  VenueAmenitiesSection(controller: controller),
                  VenueFieldSection(controller: controller),
                  if (controller.selectedField.value != null)
                    VenueTimeSlotsSection(controller: controller),
                  VenueReviewsSection(controller: controller),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              right: 12,
              child: VenueTopNav(controller: controller),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VenueBookingBar(controller: controller),
            ),
          ],
        );
      }),
    );
  }
}

class _VenueError extends StatelessWidget {
  const _VenueError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message.isNotEmpty ? message : 'Không tìm thấy sân',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
