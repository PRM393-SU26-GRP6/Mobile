import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/controller/chat_actions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> startChatWithCustomer(BookingDto booking) async {
  if (booking.userId.isEmpty) {
    Get.snackbar('Lỗi', 'Không tìm thấy thông tin khách hàng.');
    return;
  }

  Get.dialog(
    const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    barrierDismissible: false,
  );

  try {
    final room =
        await Get.find<ChatActionsController>().startWithCustomer(booking);
    if (Get.isDialogOpen == true) Get.back<void>();

    if (room == null) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng.');
      return;
    }

    await Get.toNamed(AppPages.chatDetail, arguments: room);
  } catch (_) {
    if (Get.isDialogOpen == true) Get.back<void>();
    Get.snackbar(
      'Lỗi',
      'Không thể bắt đầu cuộc trò chuyện.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
