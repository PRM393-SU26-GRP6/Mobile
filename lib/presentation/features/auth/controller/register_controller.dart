import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final UserRepository userRepository;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final selectedRole = 'Customer'.obs;
  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;

  String? _pendingEmail;

  RegisterController({required this.userRepository});

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      selectedRole.value = args;
    }
  }

  void setRole(String role) {
    selectedRole.value = role;
  }

  bool validatePassword(String password) {
    if (password.length < 8) {
      passwordError.value = 'Mật khẩu phải có ít nhất 8 ký tự';
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      passwordError.value = 'Mật khẩu phải có ít nhất 1 chữ in hoa';
      return false;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      passwordError.value = 'Mật khẩu phải có ít nhất 1 chữ số';
      return false;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      passwordError.value = 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt';
      return false;
    }
    passwordError.value = '';
    return true;
  }

  void validateConfirmPassword(String confirm, String password) {
    if (confirm.isEmpty) {
      confirmPasswordError.value = 'Vui lòng xác nhận mật khẩu';
    } else if (confirm != password) {
      confirmPasswordError.value = 'Mật khẩu xác nhận không khớp';
    } else {
      confirmPasswordError.value = '';
    }
  }

  Future<void> submitRegister() async {
    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (!validatePassword(passwordController.text)) {
      return;
    }
    validateConfirmPassword(confirmPasswordController.text, passwordController.text);
    if (confirmPasswordError.value.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;

      LoginResponseModel response;

      if (selectedRole.value == 'Owner') {
        response = await userRepository.registerOwner(
          fullName: fullNameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        );
      } else {
        response = await userRepository.registerCustomer(
          fullName: fullNameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
          confirmPassword: confirmPasswordController.text,
        );
      }

      if (response.success) {
        _pendingEmail = emailController.text;
        Get.toNamed(
          AppPages.otpVerification,
          arguments: {'email': _pendingEmail, 'isRegister': true},
        );
      } else {
        Get.snackbar('Lỗi', response.message ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
