import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showCashPaymentConfirmDialog() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Thanh toán tiền mặt'),
        ],
      ),
      content: const Text(
        'Bạn sẽ thanh toán tiền mặt trực tiếp tại sân. Vui lòng đến đúng giờ và mang theo số tiền đúng với số tiền cọc.\n\nBạn có xác nhận đặt sân không?',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Get.back<bool>(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Xác nhận'),
        ),
      ],
    ),
  );
  return result ?? false;
}
