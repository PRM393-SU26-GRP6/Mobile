import 'package:dio/dio.dart';
import 'package:exe101/app.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Init API Service
  final dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));

  final apiService = ApiServiceImpl(dio);
  Get.put(apiService);

  // Register core controllers used across routes so Get.find works from any page.
  final userRepository = UserRepository(apiService: apiService);
  Get.put<AuthController>(AuthController(userRepository: userRepository));
  Get.put<RegisterController>(
      RegisterController(userRepository: userRepository));

  // BookingController is used inside customer home pages; ensure it's available.
  Get.put<BookingController>(
      BookingController(apiService: apiService));

  runApp(const App());
}
