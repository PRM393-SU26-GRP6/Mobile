import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

/// Khởi tạo chat với khách hàng từ booking.
Future<void> startChatWithCustomer(BookingDto booking) async {
  final customerId = booking.userId;
  if (customerId.isEmpty) {
    Get.snackbar('Lỗi', 'Không tìm thấy thông tin khách hàng');
    return;
  }

  try {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    final apiService = Get.find<ApiServiceImpl>();
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final ownerId = await storage.read(key: 'user_id');

    if (ownerId == null || ownerId.isEmpty) {
      Get.back();
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin người dùng');
      return;
    }

    final chatRoom = await apiService.createChatRoom(
      CreateChatRoomRequest(customerId: customerId, ownerId: ownerId),
    );

    Get.back();
    Get.to(
      () => ChatDetailPage(chatRoom: chatRoom),
      transition: Transition.rightToLeft,
    );
  } catch (e) {
    Get.back();
    Get.snackbar(
      'Lỗi',
      'Không thể bắt đầu cuộc trò chuyện',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
