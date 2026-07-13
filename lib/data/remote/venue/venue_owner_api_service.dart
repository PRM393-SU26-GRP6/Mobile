import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/venue_model.dart';

/// Owner-side venue CRUD + venue-scoped field endpoints.
/// Customer browse lives in `venue_api_service.dart`; top-level field CRUD
/// lives in `field_api_service.dart`.
///
/// Venues:
/// - GET  /api/v1/owner/venues
/// - POST /api/v1/owner/venues
/// - PUT  /api/v1/owner/venues/{id}
/// - PUT  /api/v1/owner/venues/{id}/status
///
/// Fields (under a venue):
/// - POST /api/v1/owner/venues/{venueId}/fields
/// - GET  /api/v1/owner/venues/{venueId}/fields
class VenueOwnerApiService extends BaseApiService {
  VenueOwnerApiService(super.dio);

  /// GET /api/v1/owner/venues
  Future<List<VenueModel>> getMyVenues({
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (isActive != null) params['isActive'] = isActive;
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/venues',
      queryParameters: params,
      options: Options(headers: headers),
    );
    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// POST /api/v1/owner/venues
  Future<VenueModel> createVenue({
    required String venueName,
    required String address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/venues',
      data: {
        'venueName': venueName,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (description != null) 'description': description,
        if (openingHours != null) 'openingHours': openingHours,
        if (phoneContact != null) 'phoneContact': phoneContact,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return VenueModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// PUT /api/v1/owner/venues/{id}
  Future<VenueModel> updateVenue({
    required String venueId,
    String? venueName,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) async {
    final headers = await authJsonHeaders();
    final payload = <String, dynamic>{};
    if (venueName != null) payload['venueName'] = venueName;
    if (address != null) payload['address'] = address;
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
    if (description != null) payload['description'] = description;
    if (openingHours != null) payload['openingHours'] = openingHours;
    if (phoneContact != null) payload['phoneContact'] = phoneContact;
    final response = await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId',
      data: payload,
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return VenueModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// PUT /api/v1/owner/venues/{id}/status
  Future<void> updateVenueStatus(String venueId, bool isActive) async {
    final headers = await authJsonHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/status',
      data: {'isActive': isActive},
      options: Options(headers: headers),
    );
  }

  /// POST /api/v1/owner/venues/{venueId}/fields
  Future<FieldModel> createOwnerField({
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
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/fields',
      data: {
        'fieldName': fieldName,
        'fieldType': fieldType,
        if (description != null) 'description': description,
        if (priceMorning != null) 'priceMorning': priceMorning,
        if (priceAfternoon != null) 'priceAfternoon': priceAfternoon,
        if (priceEvening != null) 'priceEvening': priceEvening,
        if (amenities != null) 'amenities': amenities,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  /// GET /api/v1/owner/venues/{venueId}/fields
  Future<List<FieldModel>> getOwnerFieldsByVenue(String venueId) async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/fields',
      options: Options(headers: headers),
    );
    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            FieldModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
