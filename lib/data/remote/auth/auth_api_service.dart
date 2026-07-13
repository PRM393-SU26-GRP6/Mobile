import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Authentication endpoints:
/// - POST   /api/v1/auth/login
/// - POST   /api/v1/auth/register/customer
/// - POST   /api/v1/auth/register/owner
/// - POST   /api/v1/auth/verify-otp
/// - POST   /api/v1/auth/resend-otp
/// - POST   /api/v1/auth/logout
/// - POST   /api/v1/auth/refresh-token
///
/// Side-effects:
/// - `login` / `verifyOtp` persist tokens and user role/id into secure storage.
/// - `logout` calls the endpoint best-effort then clears local storage.
/// - `refreshToken` rotates access + refresh tokens in storage.
class AuthApiService extends BaseApiService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  AuthApiService(super.dio);

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/login',
      data: {'email': email, 'password': password},
      options: Options(headers: jsonHeaders()),
    );

    final loginResponse = LoginResponseModel.fromJson(response.data ?? {});

    if (loginResponse.success && loginResponse.data != null) {
      await _storage.write(
        key: BaseApiService.accessTokenKey,
        value: loginResponse.data!.accessToken ?? '',
      );
      await _storage.write(
        key: BaseApiService.refreshTokenKey,
        value: loginResponse.data!.refreshToken ?? '',
      );
      await _saveUserRole(loginResponse.data!.user);
    }

    return loginResponse;
  }

  Future<LoginResponseModel> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/register/customer',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      options: Options(headers: jsonHeaders()),
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/register/owner',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
      options: Options(headers: jsonHeaders()),
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> verifyOtp(String email, String otp) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/verify-otp',
      data: {'email': email, 'otp': otp},
      options: Options(headers: jsonHeaders()),
    );

    final verifyResponse = LoginResponseModel.fromJson(response.data ?? {});

    if (verifyResponse.success && verifyResponse.data != null) {
      await _storage.write(
        key: BaseApiService.accessTokenKey,
        value: verifyResponse.data!.accessToken ?? '',
      );
      await _storage.write(
        key: BaseApiService.refreshTokenKey,
        value: verifyResponse.data!.refreshToken ?? '',
      );
      await _saveUserRole(verifyResponse.data!.user);
    }

    return verifyResponse;
  }

  Future<void> resendOtp(String email) async {
    await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/resend-otp',
      data: {'email': email},
      options: Options(headers: jsonHeaders()),
    );
  }

  Future<void> logout() async {
    try {
      final headers = await authHeaders();
      if (headers.isNotEmpty) {
        await dio.post<Map<String, dynamic>>(
          '${Env.baseUrl}/api/v1/auth/logout',
          options: Options(headers: headers),
        );
      }
    } catch (_) {
      // best-effort: ignore remote failure and still clear local state
    }
    await _clearAuth();
  }

  Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: BaseApiService.refreshTokenKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/auth/refresh-token',
        data: {'refreshToken': refresh},
        options: Options(headers: jsonHeaders()),
      );

      if (response.data == null) return false;

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;
      if (data == null) return false;

      final success = data['success'] ?? false;
      if (!success) return false;

      final authData = data['data'];
      if (authData is! Map<String, dynamic>) return false;

      final newAccessToken = authData['accessToken'] as String?;
      final newRefreshToken = authData['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _storage.write(
          key: BaseApiService.accessTokenKey,
          value: newAccessToken,
        );
      }
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(
          key: BaseApiService.refreshTokenKey,
          value: newRefreshToken,
        );
      }

      return newAccessToken != null && newAccessToken.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // --- Token / role accessors (read-only, used by splash & auth controllers) ---

  Future<String?> getAccessToken() => readAccessToken();

  Future<String?> getUserRole() =>
      _storage.read(key: BaseApiService.userRoleKey);

  Future<String?> getUserId() => _storage.read(key: BaseApiService.userIdKey);

  // --- private helpers ---

  Future<void> _saveUserRole(UserAuthData? user) async {
    if (user != null && user.roles != null && user.roles!.isNotEmpty) {
      await _storage.write(
        key: BaseApiService.userRoleKey,
        value: user.roles!.first,
      );
    }
    if (user != null && user.id != null && user.id!.isNotEmpty) {
      await _storage.write(
        key: BaseApiService.userIdKey,
        value: user.id!,
      );
    }
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: BaseApiService.accessTokenKey);
    await _storage.delete(key: BaseApiService.refreshTokenKey);
    await _storage.delete(key: BaseApiService.userRoleKey);
    await _storage.delete(key: BaseApiService.userIdKey);
  }
}
