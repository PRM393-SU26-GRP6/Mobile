import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Hiển thị dialog xác nhận đăng xuất. Dùng chung cho owner pages.
Future<void> showOwnerLogoutDialog(BuildContext context) async {
  final authController = Get.find<AuthController>();
  if (authController.isLoggingOut.value) return;

  final shouldLogout = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Đăng xuất'),
      content: const Text('Bạn có muốn đăng xuất không?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(result: true),
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );

  if (shouldLogout != true) return;

  Get.dialog<void>(
    const PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 14),
                Text('Đang đăng xuất...'),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
  await authController.logout();
}

/// Hiển thị dialog xác nhận 2 nút Yes/No tổng quát.
/// Trả về true nếu user chọn "Xác nhận", false nếu "Hủy" hoặc back.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmText = 'Xác nhận',
  String cancelText = 'Hủy',
  Color confirmColor = AppColors.primary,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(result: true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
