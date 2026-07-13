import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';

/// All booking endpoints (customer + owner).
///
/// Customer:
/// - POST /api/v1/bookings
/// - GET  /api/v1/bookings/history
/// - GET  /api/v1/bookings/{id}
/// - PUT  /api/v1/bookings/{id}/cancel
/// - PUT  /api/v1/bookings/{id}/status
///
/// Owner:
/// - GET  /api/v1/owner/bookings
/// - GET  /api/v1/owner/bookings/pending
/// - PUT  /api/v1/owner/bookings/{id}/accept
/// - PUT  /api/v1/owner/bookings/{id}/reject
/// - PUT  /api/v1/owner/bookings/{id}/complete
///
/// Note: `getOwnerBookingById` lives in `owner_resource_api_service.dart`.
class BookingApiService extends BaseApiService {
  BookingApiService(super.dio);

  // --- Customer ---

  Future<BookingDto> createBooking({
    required List<String> slotIds,
    required String discountCode,
    required String note,
  }) async {
    final headers = await authJsonHeaders();
    final payload = <String, dynamic>{
      'slotIds': slotIds,
      'note': note,
    };
    if (discountCode.isNotEmpty) payload['discountCode'] = discountCode;

    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings',
      data: payload,
      options: Options(headers: headers),
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return BookingDto.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<List<BookingDto>> getBookingHistory({
    String? status,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/bookings/history',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final items = BaseApiService.extractList(response.data);
    return items
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<BookingDto?> getBookingById(String bookingId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId',
      options: Options(headers: headers),
    );

    if (response.data == null) return null;
    final data = response.data!['data'] ?? response.data;
    if (data is! Map<String, dynamic>) return null;
    return BookingDto.fromJson(data);
  }

  Future<void> cancelBooking(
    String bookingId, {
    String? cancellationReason,
  }) async {
    final headers = await authJsonHeaders();
    final params = <String, dynamic>{};
    if (cancellationReason != null && cancellationReason.isNotEmpty) {
      params['cancellationReason'] = cancellationReason;
    }
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId/cancel',
      data: params,
      options: Options(headers: headers),
    );
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final headers = await authJsonHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId/status',
      data: {'status': status},
      options: Options(headers: headers),
    );
  }

  // --- Owner ---

  Future<List<BookingDto>> getOwnerBookings({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/bookings',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<BookingDto>> getPendingBookings() async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/bookings/pending',
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<void> acceptBooking(String bookingId) async {
    final headers = await authHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/accept',
      options: Options(headers: headers),
    );
  }

  Future<void> rejectBooking(
    String bookingId, {
    String? rejectionReason,
  }) async {
    final headers = await authJsonHeaders();
    final params = <String, dynamic>{};
    if (rejectionReason != null) params['rejectionReason'] = rejectionReason;
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/reject',
      data: params,
      options: Options(headers: headers),
    );
  }

  Future<void> completeBooking(String bookingId) async {
    final headers = await authHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/complete',
      options: Options(headers: headers),
    );
  }
}
