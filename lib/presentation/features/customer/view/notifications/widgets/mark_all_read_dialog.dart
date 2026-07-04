import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showMarkAllReadDialog(NotificationController controller) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Đánh dấu đã đọc',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: const Text(
        'Bạn có muốn đánh dấu tất cả thông báo là đã đọc?',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: const Text(
            'Hủy',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () async {
            Get.back<bool>(result: true);
            await controller.markAllAsRead();
          },
          child: const Text(
            'Đánh dấu',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
