import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/shared/customer_helpers.dart';
import 'package:exe101/presentation/features/customer/shared/booking_card_presentation.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_payment_buttons.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/booking_card_review_section.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_sheet.dart';
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
                    booking.venueName,
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
              booking.slotSummary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking.dateRange,
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
                  booking.priceText,
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
            if (booking.isCompleted)
              BookingCardReviewSection(
                booking: booking,
                controller: controller,
              ),
          ],
        ),
      ),
    );
  }

  bool get _showPaymentButtons =>
      booking.canPayDeposit || booking.canPayRemaining;

  void _onDepositTap() {
    Get.toNamed(
      AppPages.selectPaymentMethod,
      arguments: {
        'bookingId': booking.id,
        'venueName': booking.venueName,
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
        'venueName': booking.venueName,
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
