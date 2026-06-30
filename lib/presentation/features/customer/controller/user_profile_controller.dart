import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  final UserRepository userRepository;

  final user = Rxn<UserAuthData>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final error = ''.obs;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  UserProfileController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      final profile = await userRepository.getUserProfile();
      if (profile != null) {
        user.value = profile;
        nameController.text = profile.fullName ?? '';
        phoneController.text = profile.phoneNumber ?? '';
      }
    } catch (e) {
      error.value = 'Không thể tải thông tin profile';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập họ tên',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isSaving.value = true;

      final success = await userRepository.updateUserProfile(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (success) {
        Get.snackbar(
          'Thành công',
          'Cập nhật profile thành công',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        await loadProfile();
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          'Cập nhật profile thất bại',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi cập nhật',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  void resetForm() {
    if (user.value != null) {
      nameController.text = user.value!.fullName ?? '';
      phoneController.text = user.value!.phoneNumber ?? '';
    }
  }
}
