import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showPaymentSuccessDialog() async {
  Get.dialog(
    AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text('Thanh toán thành công'),
        ],
      ),
      content: const Text('Thanh toán của bạn đã được xác nhận. Cảm ơn bạn!'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            Get.back(result: true);
            if (Get.isRegistered<BookingController>()) {
              Get.find<BookingController>().refreshBookings();
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
