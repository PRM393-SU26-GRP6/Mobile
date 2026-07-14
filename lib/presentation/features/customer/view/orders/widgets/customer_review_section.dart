import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/create_review_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/delete_review_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerReviewSection extends StatefulWidget {
  final BookingDto booking;

  const CustomerReviewSection({super.key, required this.booking});

  @override
  State<CustomerReviewSection> createState() => _CustomerReviewSectionState();
}

class _CustomerReviewSectionState extends State<CustomerReviewSection> {
  late Future<ReviewModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadReview();
  }

  Future<ReviewModel?> _loadReview() async {
    if (!Get.isRegistered<BookingController>()) return null;
    final controller = Get.find<BookingController>();
    final cached = controller.reviewForBooking(widget.booking.id);
    if (cached != null) return cached;
    final dto = await controller.loadBookingReview(widget.booking.id);
    if (dto == null) return null;
    return controller.reviewForBooking(widget.booking.id);
  }

  void _reload() {
    setState(() {
      _future = _loadReview();
    });
  }

  Future<void> _edit(ReviewModel review) async {
    final success = await ReviewFormDialog.showEdit(widget.booking, review);
    if (!success) return;
    if (Get.isRegistered<BookingController>()) {
      await Get.find<BookingController>().loadMyReviews();
    }
    _reload();
  }

  Future<void> _delete(ReviewModel review) async {
    final confirmed = await showDeleteReviewDialog();
    if (!confirmed || !Get.isRegistered<BookingController>()) return;
    final controller = Get.find<BookingController>();
    await controller.deleteReview(review.reviewId);
    controller.removeReviewForBooking(widget.booking.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReviewModel?>(
      future: _future,
      builder: (context, snapshot) {
        final review = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (review == null) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inputBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${review.rating}/5',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _edit(review),
                    child: const Text('Sửa feedback'),
                  ),
                  TextButton(
                    onPressed: () => _delete(review),
                    child: const Text('Xóa feedback'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                review.displayComment,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
