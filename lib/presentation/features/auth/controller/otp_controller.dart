import 'package:exe101/core/exception/api_error_handler.dart';
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/session_state_resetter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  static const int otpLength = 6;

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
    applyRouteArguments(Get.arguments);
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void applyRouteArguments(dynamic args) {
    if (args is! Map<String, dynamic>) return;

    final nextEmail = (args['email'] as String?)?.trim() ?? '';
    final nextIsRegister = args['isRegister'] == true;

    if (nextEmail.isNotEmpty && nextEmail != email) {
      email = nextEmail;
      otpController.clear();
    }
    isRegister = nextIsRegister;
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
    FocusManager.instance.primaryFocus?.unfocus();
    if (otpController.text.length < otpLength) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ mã OTP');
      return;
    }

    if (email.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy email để xác thực OTP');
      return;
    }

    try {
      isLoading.value = true;

      final response =
          await userRepository.verifyOtp(email, otpController.text);

      if (response.success) {
        Get.snackbar('Thành công', 'Xác thực thành công!');
        final role = await Get.find<ApiServiceImpl>().getUserRole();
        await SessionStateResetter.clearUserBoundState();
        if (role == 'Owner') {
          Get.offAllNamed(AppPages.ownerHome);
        } else {
          Get.offAllNamed(AppPages.customerHome);
        }
      } else {
        Get.snackbar('Lỗi', response.message ?? 'Mã OTP không hợp lệ');
      }
    } catch (e) {
      Get.snackbar('Lỗi', ApiErrorHandler.getMessage(e));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResend.value) return;
    if (email.isEmpty) return;

    try {
      isLoading.value = true;
      await userRepository.resendOtp(email);
      Get.snackbar('Thông báo', 'Đã gửi lại mã OTP đến $email');
      _startCountdown();
    } catch (e) {
      Get.snackbar('Lỗi', ApiErrorHandler.getMessage(e));
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  void onOtpChanged(String value) {
    if (value.length == otpLength) {
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
