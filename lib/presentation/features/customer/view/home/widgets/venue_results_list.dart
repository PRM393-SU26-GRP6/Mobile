import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/home_venue_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueResultsList extends StatelessWidget {
  final VenueController controller;

  const VenueResultsList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.venues.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        );
      }
      if (controller.error.value.isNotEmpty && controller.venues.isEmpty) {
        return _ErrorState(controller: controller);
      }
      if (controller.venues.isEmpty) return const _EmptyState();

      final extraItem = controller.hasMore.value ? 1 : 0;
      return RefreshIndicator(
        onRefresh: controller.refreshVenues,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.venues.length + extraItem,
          itemBuilder: (context, index) {
            if (index < controller.venues.length) {
              return HomeVenueCard(venue: controller.venues[index]);
            }
            return Center(
              child: controller.isLoadingMore.value
                  ? const CircularProgressIndicator()
                  : TextButton.icon(
                      onPressed: controller.loadMore,
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Xem thêm'),
                    ),
            );
          },
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  final VenueController controller;

  const _ErrorState({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(controller.error.value, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: controller.loadVenues,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text('Chưa có cụm sân phù hợp.'),
        ],
      ),
    );
  }
}
