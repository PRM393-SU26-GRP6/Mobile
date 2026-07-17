import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_review_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueReviewsSection extends StatelessWidget {
  const VenueReviewsSection({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Obx(
                () => controller.reviews.isEmpty
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.reviewAverageRating.value
                                .toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${controller.reviewTotalCount.value})',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewList(controller: controller),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.controller});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }

      if (controller.reviews.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8),
              Text(
                'Chưa có bài đánh giá nào',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          ...controller.reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: VenueReviewCard(review: review),
            ),
          ),
          if (controller.hasMoreReviews.value)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OutlinedButton(
                onPressed: controller.isLoadingMoreReviews.value
                    ? null
                    : controller.loadMoreReviews,
                child: controller.isLoadingMoreReviews.value
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Xem thêm đánh giá'),
              ),
            ),
        ],
      );
    });
  }
}
