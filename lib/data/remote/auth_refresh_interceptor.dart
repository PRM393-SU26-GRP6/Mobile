import 'package:dio/dio.dart';
import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:get/get.dart';

class AuthRefreshInterceptor extends QueuedInterceptor {
  final Dio dio;
  final ApiServiceImpl apiService;
  final Future<void> Function()? onSessionExpired;

  AuthRefreshInterceptor({
    required this.dio,
    required this.apiService,
    this.onSessionExpired,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    final statusCode = err.response?.statusCode;

    if (statusCode != 401 ||
        _isAuthEndpoint(request.path) ||
        request.extra['retriedAfterRefresh'] == true) {
      handler.next(err);
      return;
    }

    final refreshed = await apiService.refreshToken();
    if (!refreshed) {
      await _endSession();
      _routeToLogin();
      handler.next(err);
      return;
    }

    final accessToken = await apiService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      await _endSession();
      _routeToLogin();
      handler.next(err);
      return;
    }

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.extra['retriedAfterRefresh'] = true;

    try {
      final response = await dio.fetch<dynamic>(request);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/api/v1/auth/login') ||
        path.contains('/api/v1/auth/register') ||
        path.contains('/api/v1/auth/refresh-token') ||
        path.contains('/api/v1/auth/logout') ||
        path.contains('/api/v1/auth/verify-otp') ||
        path.contains('/api/v1/auth/resend-otp');
  }

  void _routeToLogin() {
    if (Get.currentRoute == AppPages.login) return;
    Get.offAllNamed(AppPages.login);
  }

  Future<void> _endSession() async {
    if (onSessionExpired != null) {
      await onSessionExpired!();
      return;
    }
    await apiService.logout();
  }
}
