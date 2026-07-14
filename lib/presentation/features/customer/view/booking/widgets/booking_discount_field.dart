import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/booking_confirmation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingDiscountField extends StatelessWidget {
  const BookingDiscountField({required this.controller, super.key});

  final BookingConfirmationController controller;

  @override
  Widget build(BuildContext context) {
    final bookingController = controller.bookingController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller.discountTextController,
                enabled: !controller.isLoading,
                decoration: const InputDecoration(
                  labelText: 'Mã giảm giá',
                  hintText: 'Nhập mã giảm giá',
                  prefixIcon: Icon(Icons.discount_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed:
                  controller.isLoading ? null : controller.validateDiscount,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              child: const Text('Áp dụng'),
            ),
          ],
        ),
        Obx(
          () => bookingController.discountMessage.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    bookingController.discountMessage.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: bookingController.isDiscountValid.value
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
