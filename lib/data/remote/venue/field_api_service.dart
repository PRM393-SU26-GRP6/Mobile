import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/field_model.dart';

/// Top-level field endpoints (not nested under a venue URL).
///
/// Venue-scoped field create/list lives in `venue_owner_api_service.dart`.
/// Lazy single-field reads used during slot management live here.
///
/// - POST   /api/v1/fields
/// - PUT    /api/v1/owner/fields/{fieldId}
/// - PUT    /api/v1/owner/fields/{fieldId}/status
/// - GET    /api/v1/fields/my-fields
/// - GET    /api/v1/fields/{fieldId}
class FieldApiService extends BaseApiService {
  FieldApiService(super.dio);

  /// POST /api/v1/fields
  Future<FieldModel> createField({
    required String venueId,
    required String fieldName,
    required String fieldType,
    String? description,
    double? priceMorning,
    double? priceAfternoon,
    double? priceEvening,
    List<String>? amenities,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/fields',
      data: {
        'venueId': venueId,
        'fieldName': fieldName,
        'fieldType': fieldType,
        'description': description,
        'priceMorning': priceMorning,
        'priceAfternoon': priceAfternoon,
        'priceEvening': priceEvening,
        'amenities': amenities,
        'isActive': true,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// PUT /api/v1/owner/fields/{fieldId}
  Future<FieldModel> updateField({
    required String fieldId,
    String? fieldName,
    String? fieldType,
    String? description,
    double? priceMorning,
    double? priceAfternoon,
    double? priceEvening,
    List<String>? amenities,
    bool? isActive,
  }) async {
    final headers = await authJsonHeaders();
    final payload = <String, dynamic>{};
    if (fieldName != null) payload['fieldName'] = fieldName;
    if (fieldType != null) payload['fieldType'] = fieldType;
    if (description != null) payload['description'] = description;
    if (priceMorning != null) payload['priceMorning'] = priceMorning;
    if (priceAfternoon != null) payload['priceAfternoon'] = priceAfternoon;
    if (priceEvening != null) payload['priceEvening'] = priceEvening;
    if (amenities != null) payload['amenities'] = amenities;
    if (isActive != null) payload['isActive'] = isActive;
    final response = await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId',
      data: payload,
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// PUT /api/v1/owner/fields/{fieldId}/status
  Future<void> updateFieldStatus(String fieldId, bool isActive) async {
    final headers = await authJsonHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/status',
      data: {'isActive': isActive},
      options: Options(headers: headers),
    );
  }

  /// GET /api/v1/fields/my-fields
  Future<List<FieldModel>> getFieldsByOwner() async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/fields/my-fields',
      options: Options(headers: headers),
    );
    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            FieldModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// GET /api/v1/fields/{fieldId}
  Future<FieldModel?> getFieldById(String fieldId) async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/fields/$fieldId',
      options: Options(headers: headers),
    );
    if (response.data == null) return null;
    if (response.data is Map<String, dynamic>) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) return FieldModel.fromJson(data);
      return FieldModel.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }
}
