// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'auth_models.dart';

class AuthApiClient {
  AuthApiClient({String? baseUrl})
    : _baseUrl = (baseUrl == null || baseUrl.isEmpty)
          ? _defaultBaseUrl
          : baseUrl;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5234/api/v1',
  );

  final String _baseUrl;

  Future<AuthResponse> login(LoginRequest request) {
    return _postAuth('auth/login', request.toJson(), 'Login failed');
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    return _postAuth('auth/register', request.toJson(), 'Register failed');
  }

  Future<AuthResponse> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) {
    return _postAuth(
      'auth/refresh-token',
      RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      'Refresh token failed',
      accessToken: accessToken,
    );
  }

  Future<AuthResponse> logout({required String accessToken}) {
    return _postAuth(
      'auth/logout',
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
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await html.HttpRequest.request(
      '$_baseUrl/$path',
      method: 'POST',
      requestHeaders: headers,
      sendData: jsonEncode(payload),
    ).timeout(const Duration(seconds: 20));

    final status = response.status ?? 0;
    final body = response.responseText ?? '';
    return _parseResponse(status, body, fallbackMessage);
  }

  AuthResponse _parseResponse(
    int statusCode,
    String body,
    String fallbackMessage,
  ) {
    Map<String, dynamic> json = {};
    if (body.trim().isNotEmpty) {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) json = decoded;
    }

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

  void dispose() {}
}
