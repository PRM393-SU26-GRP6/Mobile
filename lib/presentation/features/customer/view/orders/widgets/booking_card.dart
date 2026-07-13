import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:exe101/presentation/features/customer/view/booking/create_review_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_payment_buttons.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_sheet.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_review_actions.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/delete_review_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingCard extends StatelessWidget {
  final BookingDto booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();
    return GestureDetector(
      onTap: () => showCustomerBookingDetailsSheet(booking.id),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _venueName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: booking.bookingStatus ?? ''),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _slotSummary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dateRange,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _priceText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  timeAgoVN(booking.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            if (_showPaymentButtons) ...[
              const SizedBox(height: 10),
              BookingPaymentButtons(
                showDeposit: booking.canPayDeposit,
                showRemaining: booking.canPayRemaining,
                onDepositTap: () => _onDepositTap(),
                onRemainingTap: () => _onRemainingTap(),
              ),
            ],
            if (_isCompleted())
              Obx(() {
                final hasReview = controller.myReviews.containsKey(booking.id);
                if (!hasReview) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _buildCreateReviewButton(context, controller),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: BookingReviewActions(
                    onEditTap: () => _onEditReview(context, controller),
                    onDeleteTap: () => _onDeleteReview(context, controller),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateReviewButton(
      BuildContext context, BookingController controller) {
    return GestureDetector(
      onTap: () => _onCreateReview(context, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Đánh giá',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCompleted() => booking.bookingStatus?.toLowerCase() == 'completed';

  Future<void> _onCreateReview(
      BuildContext context, BookingController controller) async {
    final success = await ReviewFormDialog.showCreate(booking);
    if (!success) return;
    await controller.loadMyReviews();
  }

  Future<void> _onEditReview(
      BuildContext context, BookingController controller) async {
    ReviewModel? existing = controller.reviewForBooking(booking.id);
    if (existing == null) {
      // Cache miss — fall back to a single-booking lookup before showing
      // the edit form. Avoids forcing `loadMyReviews()` (which fetches all).
      await controller.loadBookingReview(booking.id);
      existing = controller.reviewForBooking(booking.id);
      if (existing == null) {
        Get.snackbar(
          'Thông báo',
          'Không tìm thấy đánh giá cho booking này',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
        );
        return;
      }
    }
    final success = await ReviewFormDialog.showEdit(booking, existing);
    if (!success) return;
    await controller.loadMyReviews();
  }

  Future<void> _onDeleteReview(
      BuildContext context, BookingController controller) async {
    final existing = controller.reviewForBooking(booking.id);
    if (existing == null) return;

    final confirmed = await showDeleteReviewDialog();
    if (!confirmed) return;

    try {
      await controller.deleteReview(existing.reviewId);
      controller.removeReviewForBooking(booking.id);
      Get.snackbar(
        'Thành công',
        'Đã xóa đánh giá',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa đánh giá. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  String get _venueName {
    if (booking.items != null && booking.items!.isNotEmpty) {
      return booking.items!.first.venueName ?? 'Sân bóng';
    }
    return 'Sân bóng';
  }

  String get _slotSummary {
    final itemCount = booking.items?.length ?? 0;
    if (itemCount == 0) return 'Chưa có thông tin slot';
    final first = booking.items!.first;
    final fieldName = first.fieldName ?? 'Sân';
    return '$fieldName · $itemCount khung giờ';
  }

  String get _dateRange {
    if (booking.items == null || booking.items!.isEmpty) {
      return '';
    }
    final dates = booking.items!
        .map((i) =>
            '${i.startTime.day}/${i.startTime.month}/${i.startTime.year}')
        .toSet()
        .toList()
      ..sort();
    if (dates.length == 1) return 'Ngày: ${dates.first}';
    return 'Ngày: ${dates.first} → ${dates.last}';
  }

  String get _priceText {
    if (booking.discountAmount > 0) {
      return '${booking.totalPrice.toStringAsFixed(0)}đ (-${booking.discountAmount.toStringAsFixed(0)}đ)';
    }
    return '${booking.totalPrice.toStringAsFixed(0)}đ';
  }

  bool get _showPaymentButtons =>
      booking.canPayDeposit || booking.canPayRemaining;

  void _onDepositTap() {
    Get.toNamed(
      AppPages.selectPaymentMethod,
      arguments: {
        'bookingId': booking.id,
        'venueName': _venueName,
        'totalPrice': booking.totalPrice,
        'paymentAmount': booking.depositAmount > 0
            ? booking.depositAmount
            : booking.totalPrice * 0.3,
        'paymentType': 'deposit',
      },
    )?.then((_) {
      if (Get.isRegistered<BookingController>()) {
        Get.find<BookingController>().refreshBookings();
      }
    });
  }

  void _onRemainingTap() {
    Get.toNamed(
      AppPages.selectPaymentMethod,
      arguments: {
        'bookingId': booking.id,
        'venueName': _venueName,
        'totalPrice': booking.totalPrice,
        'paymentAmount': booking.totalPrice - booking.paidDepositAmount,
        'paymentType': 'final',
      },
    )?.then((_) {
      if (Get.isRegistered<BookingController>()) {
        Get.find<BookingController>().refreshBookings();
      }
    });
  }
}
