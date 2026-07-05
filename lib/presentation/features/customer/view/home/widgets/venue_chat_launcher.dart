import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/chat_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

Future<Map<String, String>?> _getCurrentUser() async {
  try {
    final apiService = Get.find<ApiServiceImpl>();
    final token = await apiService.getAccessToken();
    if (token == null) return null;

    final userId = await _storage.read(key: 'user_id');
    if (userId != null) {
      return {'id': userId};
    }
  } catch (_) {}
  return null;
}

Future<void> _doStartChat(VenueModel venue) async {
  if (venue.ownerId == null || venue.ownerId!.isEmpty) return;

  try {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    final apiService = Get.find<ApiServiceImpl>();
    final userData = await _getCurrentUser();

    if (userData == null) {
      Get.back();
      Get.snackbar('Lỗi', 'Vui lòng đăng nhập để nhắn tin');
      return;
    }

    final chatRoom = await apiService.createChatRoom(
      CreateChatRoomRequest(
        customerId: userData['id']!,
        ownerId: venue.ownerId!,
        venueId: venue.id,
      ),
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

Future<void> startChatWithVenueOwner(
  VenueModel? venue, {
  void Function(VenueModel updatedVenue)? onVenueUpdated,
}) async {
  if (venue == null) return;

  if (venue.ownerId == null || venue.ownerId!.isEmpty) {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        barrierDismissible: false,
      );

      final apiService = Get.find<ApiServiceImpl>();
      final updatedVenue = await apiService.getVenueById(venue.id);
      Get.back();

      if (updatedVenue == null || updatedVenue.ownerId == null) {
        Get.snackbar(
          'Thông báo',
          'Hiện tại không thể nhắn tin với chủ sân',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      onVenueUpdated?.call(updatedVenue);
      await _doStartChat(updatedVenue);
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Lỗi',
        'Không thể tải thông tin chủ sân',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    return;
  }

  await _doStartChat(venue);
}
