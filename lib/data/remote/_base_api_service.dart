import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared base for every focused remote service in `data/remote/`.
///
/// Centralizes:
/// - the access-token secure storage key + read logic
/// - `Authorization: Bearer` header builder
/// - JSON header builder
/// - tolerant list unwrapping for paginated/scalar response shapes
///
/// Keeping these helpers here avoids copy-pasting the same private methods
/// into each new focused service.
abstract class BaseApiService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userProfileKey = 'user_profile';

  final Dio dio;

  BaseApiService(this.dio);

  /// Reads the current access token from secure storage.
  /// Returns null when no token is persisted.
  Future<String?> readAccessToken() => _storage.read(key: accessTokenKey);

  Future<String?> readSecureValue(String key) => _storage.read(key: key);

  Future<void> writeSecureValue(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> deleteSecureValue(String key) => _storage.delete(key: key);

  /// Returns `Authorization: Bearer <token>` header when a token exists,
  /// otherwise an empty map. Use with `Options(headers: ...)` on Dio calls.
  Future<Map<String, String>> authHeaders() async {
    final token = await readAccessToken();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  /// Returns headers with `Content-Type: application/json` only.
  /// Use for GET requests that need to override Dio defaults.
  Map<String, String> jsonHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Builds auth headers + JSON content-type in one call for
  /// POST/PUT/PATCH/DELETE that need to send a body.
  Future<Map<String, String>> authJsonHeaders() async {
    final headers = await authHeaders();
    headers['Content-Type'] = 'application/json';
    return headers;
  }

  /// Tolerant list unwrapping. Supports these response shapes:
  /// - `[ ... ]`                              (direct list)
  /// - `{ "data": [ ... ] }`
  /// - `{ "data": { "items": [ ... ] } }`
  /// - `{ "items": [ ... ] }`
  /// - `{ "results": [ ... ] }`
  static List<dynamic> extractList(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) return raw;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) return items;
      }
      final items = raw['items'];
      if (items is List) return items;
      final results = raw['results'];
      if (results is List) return results;
    }
    return const [];
  }

  /// Some endpoints wrap a single object inside `{ "data": {...} }`,
  /// others return the object directly. This helper picks the right one
  /// and returns it as a `Map<String, dynamic>` (or `{}` when missing).
  static Map<String, dynamic> unwrapData(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return const <String, dynamic>{};
  }
}
