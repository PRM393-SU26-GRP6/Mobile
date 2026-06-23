import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  final UserRepository userRepository;

  final otpController = TextEditingController();
  final focusNode = FocusNode();

  final isLoading = false.obs;
  final countdown = 60.obs;
  final canResend = false.obs;

  String email = '';
  bool isRegister = false;

  OtpController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      email = args['email'] ?? '';
      isRegister = args['isRegister'] ?? false;
    }
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _startCountdown() {
    countdown.value = 60;
    canResend.value = false;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (countdown.value > 0) {
        countdown.value--;
        return true;
      } else {
        canResend.value = true;
        return false;
      }
    });
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 4) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ mã OTP');
      return;
    }

    try {
      isLoading.value = true;

      final response = await userRepository.verifyOtp(email, otpController.text);

      if (response.success) {
        Get.snackbar('Thành công', 'Xác thực thành công!');
        final role = await Get.find<ApiServiceImpl>().getUserRole();
        if (role == 'Owner') {
          Get.offAllNamed(AppPages.ownerHome);
        } else {
          Get.offAllNamed(AppPages.customerHome);
        }
      } else {
        Get.snackbar('Lỗi', response.message ?? 'Mã OTP không hợp lệ');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    if (!canResend.value) return;
    Get.snackbar('Thông báo', 'Đã gửi lại mã OTP đến $email');
    _startCountdown();
  }

  void onOtpChanged(String value) {
    if (value.length == 4) {
      HapticFeedback.lightImpact();
      verifyOtp();
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
