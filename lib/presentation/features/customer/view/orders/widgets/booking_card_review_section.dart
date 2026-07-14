import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/view/booking/create_review_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_review_actions.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/delete_review_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingCardReviewSection extends StatelessWidget {
  const BookingCardReviewSection({
    super.key,
    required this.booking,
    required this.controller,
  });

  final BookingDto booking;
  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasReview = controller.hasReviewFor(booking.id);
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: hasReview
            ? BookingReviewActions(
                onEditTap: _editReview,
                onDeleteTap: _deleteReview,
              )
            : Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _createReview,
                  icon: const Icon(Icons.star_rounded, size: 16),
                  label: const Text('Đánh giá'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
      );
    });
  }

  Future<void> _createReview() async {
    if (await ReviewFormDialog.showCreate(booking)) {
      await controller.loadMyReviews();
    }
  }

  Future<void> _editReview() async {
    var review = controller.reviewForBooking(booking.id);
    review ??= await _loadReview();
    if (review == null) {
      Get.snackbar('Thông báo', 'Không tìm thấy đánh giá này');
      return;
    }
    if (await ReviewFormDialog.showEdit(booking, review)) {
      await controller.loadMyReviews();
    }
  }

  Future<dynamic> _loadReview() async {
    await controller.loadBookingReview(booking.id);
    return controller.reviewForBooking(booking.id);
  }

  Future<void> _deleteReview() async {
    final review = controller.reviewForBooking(booking.id);
    if (review == null || !await showDeleteReviewDialog()) return;
    try {
      await controller.deleteReview(review.reviewId);
      controller.removeReviewForBooking(booking.id);
      Get.snackbar('Thành công', 'Đã xóa đánh giá');
    } catch (_) {
      Get.snackbar('Lỗi', 'Không thể xóa đánh giá. Vui lòng thử lại.');
    }
  }
}
