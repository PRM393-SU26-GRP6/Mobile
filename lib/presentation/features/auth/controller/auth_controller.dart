import 'dart:convert';

import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/user_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String userModelToJson(UserModel user) => jsonEncode(user.toJson());

class AuthController extends GetxController {
  final UserRepository userRepository;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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
      Get.snackbar('Lỗi', ApiErrorHandler.getMessage(e));
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

  // Mock login for Owner (development only)
  Future<void> loginAsMockOwner() async {
    try {
      isLoading.value = true;

      final mockUser = UserModel(
        id: 'owner-mock-id-001',
        tenDangNhap: 'owner_mock',
        hoVaTen: 'Owner Mock Account',
        email: 'owner@mock.com',
        soDienThoai: '0909123456',
        vaiTro: 'Owner',
        isActive: true,
        thoiGianTao: DateTime.now(),
      );

      final mockToken = 'mock_jwt_token_owner_123456789';

      await _storage.write(key: 'accessToken', value: mockToken);
      await _storage.write(key: 'user', value: userModelToJson(mockUser));

      Get.snackbar('Thành công', 'Đăng nhập Owner (Mock)');
      Get.offAllNamed(AppPages.ownerHome);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đăng nhập mock');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
