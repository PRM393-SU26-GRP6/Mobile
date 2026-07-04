import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Hiển thị dialog xác nhận đăng xuất. Dùng chung cho owner pages.
Future<void> showOwnerLogoutDialog(BuildContext context) async {
  return Get.dialog(
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
          onPressed: () {
            Get.back();
            Get.find<AuthController>().logout();
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
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
