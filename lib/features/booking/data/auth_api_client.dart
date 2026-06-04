import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'auth_models.dart';

class AuthApiClient {
  AuthApiClient({String? baseUrl, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: (baseUrl == null || baseUrl.isEmpty)
                  ? _defaultBaseUrl
                  : baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Content-Type': 'application/json'},
              validateStatus: (_) => true,
            ),
          );

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5234/api/v1';
    }
    return 'http://localhost:5234/api/v1';
  }

  final Dio _dio;

  Future<AuthResponse> login(LoginRequest request) {
    return _postAuth('/auth/login', request.toJson(), 'Login failed');
  }

  Future<AuthResponse> register(RegisterRequest request) {
    return _postAuth('/auth/register', request.toJson(), 'Register failed');
  }

  Future<AuthResponse> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) {
    return _postAuth(
      '/auth/refresh-token',
      RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      'Refresh token failed',
      accessToken: accessToken,
    );
  }

  Future<AuthResponse> logout({required String accessToken}) {
    return _postAuth(
      '/auth/logout',
      const {},
      'Logout failed',
      accessToken: accessToken,
    );
  }

  Future<AuthResponse> _postAuth(
    String path,
    Map<String, dynamic> payload,
    String fallbackMessage, {
    String? accessToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: payload,
        options: Options(
          headers: accessToken == null || accessToken.isEmpty
              ? null
              : {'Authorization': 'Bearer $accessToken'},
        ),
      );

      return _parseResponse(
        response.statusCode ?? 0,
        response.data,
        fallbackMessage,
      );
    } on DioException catch (error) {
      throw AuthApiException(_messageFromDio(error, fallbackMessage));
    }
  }

  AuthResponse _parseResponse(
    int statusCode,
    Object? data,
    String fallbackMessage,
  ) {
    final json = _jsonFromResponse(data);
    final authResponse = AuthResponse.fromJson(json);
    if (statusCode >= 200 && statusCode < 300 && authResponse.success) {
      return authResponse;
    }

    throw AuthApiException(
      authResponse.message.isNotEmpty
          ? authResponse.message
          : '$fallbackMessage. Status code: $statusCode',
    );
  }

  Map<String, dynamic> _jsonFromResponse(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return {};
  }

  String _messageFromDio(DioException error, String fallbackMessage) {
    final response = error.response;
    if (response != null) {
      final authResponse = AuthResponse.fromJson(
        _jsonFromResponse(response.data),
      );
      if (authResponse.message.isNotEmpty) return authResponse.message;
      return '$fallbackMessage. Status code: ${response.statusCode ?? 0}';
    }
    return error.message ?? fallbackMessage;
  }

  void dispose() {
    _dio.close(force: true);
  }
}
