import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final UserRepository userRepository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  AuthController({required this.userRepository});

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập email và mật khẩu');
      return;
    }

    try {
      isLoading.value = true;
      final loginResponse = await userRepository.login(
        emailController.text,
        passwordController.text,
      );

      if (loginResponse.success) {
        final role = await Get.find<ApiServiceImpl>().getUserRole();
        if (role == 'Owner') {
          Get.offAllNamed(AppPages.ownerHome);
        } else {
          Get.offAllNamed(AppPages.customerHome);
        }
      } else {
        Get.snackbar('Lỗi', loginResponse.message ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    if (Get.isRegistered<ApiServiceImpl>()) {
      await Get.find<ApiServiceImpl>().logout();
    }
    Get.offAllNamed(AppPages.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
