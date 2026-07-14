import 'package:exe101/core/exception/api_error_handler.dart';
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_flow_resolver.dart';
import 'package:exe101/presentation/features/auth/controller/session_state_resetter.dart';
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
        await SessionStateResetter.clearUserBoundState();
        if (role == 'Owner') {
          Get.offAllNamed(AppPages.ownerHome);
        } else {
          Get.offAllNamed(AppPages.customerHome);
        }
      } else {
        if (AuthFlowResolver.shouldOpenOtpAfterLogin(loginResponse)) {
          _openOtpVerification();
          return;
        }
        Get.snackbar('Lỗi', loginResponse.message ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      if (AuthFlowResolver.shouldOpenOtpAfterLogin(e)) {
        Get.snackbar(
          'Thông báo',
          'Tài khoản chưa xác thực email. Vui lòng nhập OTP để tiếp tục.',
        );
        _openOtpVerification();
        return;
      }
      Get.snackbar('Lỗi', ApiErrorHandler.getMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _openOtpVerification() {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    Get.toNamed(
      AppPages.otpVerification,
      arguments: {'email': email, 'isRegister': false},
    );
  }

  Future<void> logout() async {
    if (Get.isRegistered<ApiServiceImpl>()) {
      await Get.find<ApiServiceImpl>().logout();
    }
    await SessionStateResetter.clearUserBoundState();
    emailController.clear();
    passwordController.clear();
    Get.offAllNamed(AppPages.login);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
