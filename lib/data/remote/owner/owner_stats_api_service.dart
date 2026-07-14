import 'package:dio/dio.dart';

import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/revenue_model.dart';

/// Stats/Revenue endpoints:
/// - GET /api/v1/owner/stats
/// - GET /api/v1/owner/revenue
class OwnerStatsApiService extends BaseApiService {
  OwnerStatsApiService(super.dio);

  Future<Map<String, dynamic>> getOwnerStats() async {
    final headers = await authHeaders();
    final response = await dio.get(
      '${Env.baseUrl}/api/v1/owner/stats',
      options: Options(headers: headers),
    );
    return BaseApiService.unwrapData(response.data);
  }

  Future<RevenueResponse> getOwnerRevenue({
    DateTime? from,
    DateTime? to,
    String groupBy = 'day',
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{'groupBy': groupBy};
    if (from != null) params['from'] = from.toIso8601String();
    if (to != null) params['to'] = to.toIso8601String();

    final results = await Future.wait<dynamic>([
      getOwnerStats(),
      dio.get(
        '${Env.baseUrl}/api/v1/owner/revenue',
        queryParameters: params,
        options: Options(headers: headers),
      ),
    ]);

    final stats = results[0] as Map<String, dynamic>;
    final revenueResponse = results[1] as Response<dynamic>;

    final groups = <RevenuePoint>[];
    final rawGroups = BaseApiService.extractList(revenueResponse.data);
    for (final entry in rawGroups) {
      if (entry is Map<String, dynamic>) {
        groups.add(RevenuePoint.fromJson(entry));
      }
    }
    groups.sort(RevenuePoint.compareChronologically);

    return RevenueResponse(
      totalRevenue: (stats['totalRevenue'] as num?)?.toDouble() ?? 0,
      depositRevenue: (stats['depositRevenue'] as num?)?.toDouble() ?? 0,
      finalPaymentRevenue:
          (stats['finalPaymentRevenue'] as num?)?.toDouble() ?? 0,
      from: from,
      to: to,
      groupBy: groupBy,
      groups: groups,
    );
  }
}
