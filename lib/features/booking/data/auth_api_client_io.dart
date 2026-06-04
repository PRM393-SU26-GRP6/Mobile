import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'auth_models.dart';

class AuthApiClient {
  AuthApiClient({String? baseUrl})
    : _baseUrl = (baseUrl == null || baseUrl.isEmpty)
          ? _defaultBaseUrl
          : baseUrl,
      _client = HttpClient()..connectionTimeout = const Duration(seconds: 10);

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (Platform.isAndroid) return 'http://10.0.2.2:5234/api/v1';
    return 'http://localhost:5234/api/v1';
  }

  final String _baseUrl;
  final HttpClient _client;

  Future<AuthResponse> login(LoginRequest loginRequest) {
    return _postAuth('auth/login', loginRequest.toJson(), 'Login failed');
  }

  Future<AuthResponse> register(RegisterRequest registerRequest) async {
    return _postAuth(
      'auth/register',
      registerRequest.toJson(),
      'Register failed',
    );
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
    final uri = Uri.parse('$_baseUrl/$path');
    final request = await _client
        .postUrl(uri)
        .timeout(const Duration(seconds: 10));
    request.headers.contentType = ContentType.json;
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $accessToken',
      );
    }
    request.write(jsonEncode(payload));

    final response = await request.close().timeout(const Duration(seconds: 20));
    final body = await utf8.decoder.bind(response).join();

    return _parseResponse(response.statusCode, body, fallbackMessage);
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

  void dispose() {
    _client.close(force: true);
  }
}
