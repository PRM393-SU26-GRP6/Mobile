import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OwnerBookingReviewSection extends StatelessWidget {
  const OwnerBookingReviewSection({super.key, required this.booking});

  final BookingDto booking;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReviewModel?>(
      future:
          Get.find<BookingManagementController>().fetchBookingReview(booking),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: LinearProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return const _ReviewMessage('Không thể tải đánh giá cho đơn này.');
        }
        final review = snapshot.data;
        if (review == null) {
          return const _ReviewMessage('Chưa có đánh giá cho đơn này.');
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⭐ ${review.rating}/5',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                review.userName ?? 'Khách hàng',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(review.displayComment),
            ],
          ),
        );
      },
    );
  }
}

class _ReviewMessage extends StatelessWidget {
  const _ReviewMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
}
