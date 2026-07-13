import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/login_response_model.dart';

/// User-profile endpoints (any authenticated role):
/// - GET  /api/v1/users/profile
/// - PUT  /api/v1/users/profile
class UserApiService extends BaseApiService {
  UserApiService(super.dio);

  Future<UserAuthData?> getUserProfile() async {
    final cached = await _readCachedProfile();
    if (cached != null) return cached;

    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/users/profile',
      options: Options(headers: headers),
    );

    if (response.data == null) return null;

    final data = response.data!['data'] ?? response.data;
    if (data is! Map<String, dynamic>) return null;

    final user = UserAuthData.fromJson(data);
    await _cacheProfile(user);
    return user;
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final headers = await authJsonHeaders();

    final payload = <String, dynamic>{};
    if (fullName != null) payload['fullName'] = fullName;
    if (phone != null) payload['phone'] = phone;
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;

    if (payload.isEmpty) return false;

    try {
      final response = await dio.put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/users/profile',
        data: payload,
        options: Options(headers: headers),
      );
      if (response.statusCode != 200) return false;

      final current = await _readCachedProfile();
      if (current != null) {
        await _cacheProfile(current.copyWith(
          fullName: fullName,
          phoneNumber: phone,
          avatarUrl: avatarUrl,
        ));
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserAuthData?> _readCachedProfile() async {
    final raw = await readSecureValue(BaseApiService.userProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? UserAuthData.fromJson(json) : null;
    } catch (_) {
      await deleteSecureValue(BaseApiService.userProfileKey);
      return null;
    }
  }

  Future<void> _cacheProfile(UserAuthData user) => writeSecureValue(
        BaseApiService.userProfileKey,
        jsonEncode(user.toJson()),
      );
}
