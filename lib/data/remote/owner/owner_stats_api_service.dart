import 'package:dio/dio.dart';

import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/revenue_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stats/Revenue endpoints:
/// - GET /api/v1/owner/stats
/// - GET /api/v1/owner/revenue
class OwnerStatsApiService {
  final Dio dio;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  OwnerStatsApiService(this.dio);

  static const _keyAccessToken = 'access_token';

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<Map<String, dynamic>> getOwnerStats() async {
    final headers = await _authHeaders();
    final response = await dio.get(
      '${Env.baseUrl}/api/v1/owner/stats',
      options: Options(headers: headers),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<RevenueResponse> getOwnerRevenue({
    DateTime? from,
    DateTime? to,
    String groupBy = 'day',
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{'groupBy': groupBy};
    if (from != null) params['from'] = from.toIso8601String();
    if (to != null) params['to'] = to.toIso8601String();

    final response = await dio.get(
      '${Env.baseUrl}/api/v1/owner/revenue',
      queryParameters: params,
      options: Options(headers: headers),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return RevenueResponse.empty();
    }

    final groups = <RevenuePoint>[];
    final rawGroups = data['groups'] ?? data['data'] ?? data['items'];
    if (rawGroups is List) {
      for (final entry in rawGroups) {
        if (entry is Map<String, dynamic>) {
          groups.add(RevenuePoint.fromJson(entry));
        }
      }
    }

    return RevenueResponse(
      totalRevenue: (data['totalRevenue'] as num?)?.toDouble() ?? 0,
      depositRevenue: (data['depositRevenue'] as num?)?.toDouble() ?? 0,
      finalPaymentRevenue:
          (data['finalPaymentRevenue'] as num?)?.toDouble() ?? 0,
      from: from,
      to: to,
      groupBy: groupBy,
      groups: groups,
    );
  }
}
