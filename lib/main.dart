import 'package:dio/dio.dart';
import 'package:exe101/app.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/owner_resource_api_service.dart';
import 'package:exe101/data/remote/owner_stats_api_service.dart';
import 'package:exe101/data/remote/review_api_service.dart';
import 'package:exe101/data/remote/slot_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';

class ApiErrorHandler {
  static String getMessage(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      if (response?.data != null) {
        if (response!.data is Map) {
          final data = response.data as Map;
          if (data['message'] != null) {
            return data['message'].toString();
          }
          if (data['error'] != null) {
            return data['error'].toString();
          }
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Kết nối bị timeout. Vui lòng kiểm tra mạng.';
        case DioExceptionType.sendTimeout:
          return 'Không thể gửi yêu cầu. Vui lòng thử lại.';
        case DioExceptionType.receiveTimeout:
          return 'Server phản hồi chậm. Vui lòng thử lại.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode ?? 0;
          if (statusCode == 401) {
            return 'Email hoặc mật khẩu không đúng';
          } else if (statusCode == 403) {
            return 'Bạn không có quyền truy cập';
          } else if (statusCode == 404) {
            return 'Không tìm thấy dữ liệu';
          } else if (statusCode == 500) {
            return 'Lỗi server. Vui lòng thử lại sau.';
          }
          return 'Yêu cầu thất bại (Mã: $statusCode)';
        case DioExceptionType.cancel:
          return 'Yêu cầu bị hủy';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối server. Vui lòng kiểm tra mạng.';
        default:
          return 'Có lỗi xảy ra. Vui lòng thử lại.';
      }
    }
    return error.toString();
  }
}

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
    logPrint: (o) => debugPrint(o.toString(), wrapWidth: 2048),
  ));

  final apiService = ApiServiceImpl(dio);
  Get.put(apiService);

  // Focused owner services. Registered at app-level so feature bindings
  // can resolve them via Get.find without rebuilding Dio clients.
  Get.put<OwnerStatsApiService>(OwnerStatsApiService(dio));
  Get.put<OwnerResourceApiService>(OwnerResourceApiService(dio));
  Get.put<OwnerManagementRepository>(
    OwnerManagementRepository(
      statsService: Get.find<OwnerStatsApiService>(),
      resourceService: Get.find<OwnerResourceApiService>(),
    ),
  );

  // Customer slot service for unlock-slot cleanup flow.
  Get.put<SlotApiService>(SlotApiService(dio));
  Get.put<SlotRepository>(SlotRepository(slotApiService: Get.find()));

  // Customer review service for lazy booking/field rating lookups.
  Get.put<ReviewApiService>(ReviewApiService(dio));
  Get.put<ReviewRepository>(ReviewRepository(reviewApiService: Get.find()));

  // Register core controllers used across routes so Get.find works from any page.
  final userRepository = UserRepository(apiService: apiService);
  Get.put<AuthController>(AuthController(userRepository: userRepository));
  Get.put<RegisterController>(
      RegisterController(userRepository: userRepository));

  // BookingController is used inside customer home pages; ensure it's available.
  Get.put<BookingController>(BookingController(
    apiService: apiService,
    reviewRepository: Get.find<ReviewRepository>(),
  ));

  runApp(const App());
}
