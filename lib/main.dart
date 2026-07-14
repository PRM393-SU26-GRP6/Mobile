import 'package:dio/dio.dart';
import 'package:exe101/app.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/data/remote/auth_refresh_interceptor.dart';
import 'package:exe101/data/remote/owner/owner_stats_api_service.dart';
import 'package:exe101/data/remote/schedule/owner_resource_api_service.dart';
import 'package:exe101/data/remote/schedule/slot_api_service.dart';
import 'package:exe101/data/remote/shared/review_api_service.dart';
import 'package:exe101/data/remote/signalr_service.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:exe101/presentation/features/auth/controller/session_state_resetter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final apiService = ApiServiceImpl(dio);
  dio.interceptors.add(
    AuthRefreshInterceptor(
      dio: dio,
      apiService: apiService,
      onSessionExpired: () async {
        await apiService.logout();
        await SessionStateResetter.clearUserBoundState();
      },
    ),
  );

  Get.put<ApiServiceImpl>(apiService);
  Get.put<SignalRService>(SignalRService());

  Get.put<OwnerStatsApiService>(OwnerStatsApiService(dio));
  Get.put<OwnerResourceApiService>(OwnerResourceApiService(dio));
  Get.put<OwnerManagementRepository>(
    OwnerManagementRepository(
      statsService: Get.find<OwnerStatsApiService>(),
      resourceService: Get.find<OwnerResourceApiService>(),
    ),
  );

  Get.put<SlotApiService>(SlotApiService(dio));
  Get.put<SlotRepository>(SlotRepository(slotApiService: Get.find()));
  Get.put<ReviewApiService>(ReviewApiService(dio));
  Get.put<ReviewRepository>(ReviewRepository(reviewApiService: Get.find()));

  runApp(const App());
}
