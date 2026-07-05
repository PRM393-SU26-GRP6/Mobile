import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio);

  /// Hỗ trợ nhiều dạng response phân trang / trả về:
  /// - `[ ... ]` (list trực tiếp)
  /// - `{ "data": [ ... ] }`
  /// - `{ "data": { "items": [ ... ] } }`
  /// - `{ "items": [ ... ] }`
  /// - `{ "results": [ ... ] }`
  List<dynamic> _extractList(dynamic raw) {
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

  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic> params = const {},
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    return dio.get(url, queryParameters: params, options: options);
  }

  Future<Response<T>> post<T>(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    return dio.post(url, data: data, options: options);
  }

  Future<Response<T>> put<T>(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    return dio.put(url, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String url, {
    Map<String, dynamic> data = const {},
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    return dio.delete(url, data: data, options: options);
  }

  Future<Response<T>> patch<T>(String url,
      {Map<String, dynamic> data = const {}}) async {
    return dio.patch(url, data: data);
  }
}

class ApiServiceImpl extends ApiService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  ApiServiceImpl(super.dio);

  // --- Secure storage keys ---
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserRole = 'user_role';
  static const _keyUserId = 'user_id';

  Future<Map<String, String>> _authHeaders() async {
    final token = await _readToken();
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<String?> _readToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  // --- Auth methods ---

  Future<LoginResponseModel> login(String email, String password) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );

    final loginResponse = LoginResponseModel.fromJson(response.data ?? {});

    if (loginResponse.success && loginResponse.data != null) {
      await _storage.write(
        key: _keyAccessToken,
        value: loginResponse.data!.accessToken ?? '',
      );
      await _storage.write(
        key: _keyRefreshToken,
        value: loginResponse.data!.refreshToken ?? '',
      );
      await _saveUserRole(loginResponse.data!.user);
    }

    return loginResponse;
  }

  Future<LoginResponseModel> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/register/customer',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/register/owner',
      data: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> verifyOtp(String email, String otp) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/auth/verify-otp',
      data: {'email': email, 'otp': otp},
    );

    final verifyResponse = LoginResponseModel.fromJson(response.data ?? {});

    if (verifyResponse.success && verifyResponse.data != null) {
      await _storage.write(
        key: _keyAccessToken,
        value: verifyResponse.data!.accessToken ?? '',
      );
      await _storage.write(
        key: _keyRefreshToken,
        value: verifyResponse.data!.refreshToken ?? '',
      );
      await _saveUserRole(verifyResponse.data!.user);
    }

    return verifyResponse;
  }

  Future<void> logout() async {
    try {
      final headers = await _authHeaders();
      if (headers.isNotEmpty) {
        await post<Map<String, dynamic>>(
          '${Env.baseUrl}/api/v1/auth/logout',
          headers: headers,
        );
      }
    } catch (_) {}
    await _clearAuth();
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await post<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.data == null) return false;

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : null;

      if (data == null) return false;

      final success = data['success'] ?? false;
      if (!success) return false;

      final authData = data['data'];
      if (authData is! Map<String, dynamic>) return false;

      final newAccessToken = authData['accessToken'] as String?;
      final newRefreshToken = authData['refreshToken'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _storage.write(key: _keyAccessToken, value: newAccessToken);
      }
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _storage.write(key: _keyRefreshToken, value: newRefreshToken);
      }

      return newAccessToken != null && newAccessToken.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // --- Token / Role access (public, used by splash & auth controllers) ---

  Future<String?> getAccessToken() => _readToken();

  Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  Future<String?> getUserId() async {
    return _storage.read(key: _keyUserId);
  }

  // --- Private helpers ---

  Future<void> _saveUserRole(UserAuthData? user) async {
    if (user != null && user.roles != null && user.roles!.isNotEmpty) {
      await _storage.write(key: _keyUserRole, value: user.roles!.first);
    }
    if (user != null && user.id != null && user.id!.isNotEmpty) {
      await _storage.write(key: _keyUserId, value: user.id!);
    }
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserRole);
    await _storage.delete(key: _keyUserId);
  }

  // --- Venue APIs ---

  Future<List<VenueModel>> getVenues({
    String? q,
    String? fieldType,
    double? minRating,
    double? priceMin,
    double? priceMax,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'Page': page,
      'PageSize': pageSize,
    };
    if (q != null) params['Q'] = q;
    if (fieldType != null) params['FieldType'] = fieldType;
    if (minRating != null) params['MinRating'] = minRating;
    if (priceMin != null) params['PriceMin'] = priceMin;
    if (priceMax != null) params['PriceMax'] = priceMax;
    if (sort != null) params['Sort'] = sort;

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/Venues',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);
    if (list.isEmpty && response.data is Map<String, dynamic>) {
      final inner =
          _extractList((response.data as Map<String, dynamic>)['data']);
      if (inner.isNotEmpty) {
        return inner
            .map((json) =>
                VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    }

    return list
        .map((json) =>
            VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<FootballFieldDto>> getFieldsByVenue(String venueId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/Venues/$venueId/fields',
      headers: headers,
    );

    if (response.data != null && response.data!['data'] != null) {
      final List<dynamic> list = response.data!['data'];
      return list.map((json) => FootballFieldDto.fromJson(json)).toList();
    }
    return [];
  }

  Future<VenueModel?> getVenueById(String id) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/Venues/$id',
      headers: headers,
    );

    if (response.data == null) return null;

    Map<String, dynamic> venueData = response.data!['data'];
    return VenueModel.fromJson(venueData);
  }

  // --- Slot APIs ---

  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/slots/available',
      params: {'fieldId': fieldId, 'date': date},
      headers: headers,
    );

    if (response.data != null && response.data!['data'] != null) {
      final List<dynamic> list = response.data!['data'];
      return list.map((json) => TimeSlotDto.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<TimeSlotDto>> getSlotsByField(String fieldId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/slots',
      params: {'fieldId': fieldId},
      headers: headers,
    );

    if (response.data != null && response.data!['data'] != null) {
      final List<dynamic> list = response.data!['data'];
      return list.map((json) => TimeSlotDto.fromJson(json)).toList();
    }
    return [];
  }

  // --- Booking APIs ---

  Future<BookingDto> createBooking({
    required List<String> slotIds,
    required String discountCode,
    required String note,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final payload = <String, dynamic>{
      'slotIds': slotIds,
      'note': note,
    };
    if (discountCode.isNotEmpty) payload['discountCode'] = discountCode;

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings',
      data: payload,
      headers: headers,
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
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/bookings/history',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final items = _extractList(response.data);

    return items
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<BookingDto?> getBookingById(String bookingId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId',
      headers: headers,
    );

    if (response.data == null) return null;

    final data = response.data!['data'] ?? response.data;
    if (data is! Map<String, dynamic>) return null;

    return BookingDto.fromJson(data);
  }

  Future<void> cancelBooking(String bookingId,
      {String? cancellationReason}) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final params = <String, dynamic>{};
    if (cancellationReason != null && cancellationReason.isNotEmpty) {
      params['cancellationReason'] = cancellationReason;
    }

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId/cancel',
      data: params,
      headers: headers,
    );
  }

  // --- Field APIs (Owner) ---

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
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
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
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

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
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final payload = <String, dynamic>{};
    if (fieldName != null) payload['fieldName'] = fieldName;
    if (fieldType != null) payload['fieldType'] = fieldType;
    if (description != null) payload['description'] = description;
    if (priceMorning != null) payload['priceMorning'] = priceMorning;
    if (priceAfternoon != null) payload['priceAfternoon'] = priceAfternoon;
    if (priceEvening != null) payload['priceEvening'] = priceEvening;
    if (amenities != null) payload['amenities'] = amenities;
    if (isActive != null) payload['isActive'] = isActive;

    final response = await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId',
      data: payload,
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<void> updateFieldStatus(String fieldId, bool isActive) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/status',
      data: {'isActive': isActive},
      headers: headers,
    );
  }

  Future<List<FieldModel>> getFieldsByOwner() async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/fields/my-fields',
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            FieldModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<FieldModel?> getFieldById(String fieldId) async {
    final headers = await _authHeaders();
    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/fields/$fieldId',
      headers: headers,
    );

    if (response.data == null) return null;

    if (response.data is Map<String, dynamic>) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return FieldModel.fromJson(data);
      }
    }

    if (response.data is Map<String, dynamic>) {
      return FieldModel.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  // --- Owner Venue APIs ---

  Future<List<VenueModel>> getMyVenues({
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (isActive != null) params['isActive'] = isActive;

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/venues',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<VenueModel> createVenue({
    required String venueName,
    required String address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
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
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return VenueModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

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
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final payload = <String, dynamic>{};
    if (venueName != null) payload['venueName'] = venueName;
    if (address != null) payload['address'] = address;
    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
    if (description != null) payload['description'] = description;
    if (openingHours != null) payload['openingHours'] = openingHours;
    if (phoneContact != null) payload['phoneContact'] = phoneContact;

    final response = await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId',
      data: payload,
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return VenueModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<void> updateVenueStatus(String venueId, bool isActive) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/status',
      data: {'isActive': isActive},
      headers: headers,
    );
  }

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
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
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
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return FieldModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<List<FieldModel>> getOwnerFieldsByVenue(String venueId) async {
    final headers = await _authHeaders();
    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/venues/$venueId/fields',
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            FieldModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  // --- Owner Booking APIs ---

  Future<List<BookingDto>> getOwnerBookings({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/bookings',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<BookingDto>> getPendingBookings() async {
    final headers = await _authHeaders();
    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/owner/bookings/pending',
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<void> acceptBooking(String bookingId) async {
    final headers = await _authHeaders();
    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/accept',
      headers: headers,
    );
  }

  Future<void> rejectBooking(String bookingId,
      {String? rejectionReason}) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{};
    if (rejectionReason != null) params['rejectionReason'] = rejectionReason;

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/reject',
      data: params,
      headers: headers,
    );
  }

  Future<void> completeBooking(String bookingId) async {
    final headers = await _authHeaders();
    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/bookings/$bookingId/complete',
      headers: headers,
    );
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/bookings/$bookingId/status',
      data: {'status': status},
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> getOwnerStats() async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/stats',
      headers: headers,
    );

    if (response.data == null) return {};
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
  }

  // --- Payment APIs ---

  Future<List<PaymentModel>> getPaymentsByBooking(String bookingId) async {
    final headers = await _authHeaders();
    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/payments/booking/$bookingId',
      headers: headers,
    );

    if (response.data == null) return [];

    final data = response.data!;

    if (data is List) {
      return data
          .map((json) =>
              PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }

    if (data is! Map<String, dynamic>) return [];

    final listData = data['data'];
    if (listData is! List) return [];

    return listData
        .map((json) =>
            PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<PaymentModel> createDepositPayment(String bookingId,
      {String paymentMethod = 'SePay'}) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/deposit',
      data: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
      },
      headers: headers,
    );

    // Check if response is an error
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data?['message'] ?? 'Payment creation failed',
      );
    }

    // API returns payment directly without 'data' wrapper
    final data = response.data?['data'] ?? response.data ?? {};
    return PaymentModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<PaymentModel> createFinalPayment(String bookingId,
      {String paymentMethod = 'SePay'}) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/final',
      data: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
      },
      headers: headers,
    );

    // API returns payment directly without 'data' wrapper
    final data = response.data?['data'] ?? response.data ?? {};
    return PaymentModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<PaymentModel> createFullPayment(String bookingId,
      {String paymentMethod = 'SePay'}) async {
    return createFinalPayment(bookingId, paymentMethod: paymentMethod);
  }

  Future<SePayQRInfoModel?> getSePayQRInfo(String paymentId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId/sepay-qr',
      headers: headers,
    );

    if (response.data == null) return null;

    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;

    return SePayQRInfoModel.fromJson(payload);
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId',
      headers: headers,
    );

    if (response.data == null) return null;

    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;

    return PaymentModel.fromJson(payload);
  }

  Future<SePayCheckoutFormModel?> getSePayCheckout(String paymentId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId/sepay-checkout',
      headers: headers,
    );

    if (response.data == null) return null;

    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;

    return SePayCheckoutFormModel.fromJson(payload);
  }

  Future<Map<String, dynamic>?> handleSePayWebhook({
    required String transferType,
    required String transferAmount,
    required String transferDate,
    required String bankAccount,
    String? reference,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/webhook/sepay',
      data: {
        'transferType': transferType,
        'transferAmount': transferAmount,
        'transferDate': transferDate,
        'bankAccount': bankAccount,
        if (reference != null) 'reference': reference,
      },
    );

    if (response.data == null) return null;
    return response.data;
  }

  Future<Map<String, dynamic>?> handlePaymentCallback({
    required String gateway,
    required Map<String, dynamic> callbackData,
  }) async {
    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/callback/$gateway',
      data: callbackData,
    );

    if (response.data == null) return null;
    return response.data;
  }

  // ==================== SLOT MANAGEMENT ====================

  Future<void> bulkCreateSlots({
    required String fieldId,
    required BulkCreateSlotsDto slotsDto,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/slots/bulk',
      data: slotsDto.toJson(),
      headers: headers,
    );
  }

  Future<List<FieldScheduleDto>> getFieldSchedule(String fieldId) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/schedule',
      headers: headers,
    );

    if (response.data == null) return [];
    final list = _extractList(response.data);
    return list
        .map((e) => FieldScheduleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FieldScheduleDto>> updateFieldSchedule({
    required String fieldId,
    required List<FieldScheduleRowDto> rows,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/schedule',
      data: {'rows': rows.map((e) => e.toJson()).toList()},
      headers: headers,
    );

    if (response.data == null) return [];
    final list = _extractList(response.data);
    return list
        .map((e) => FieldScheduleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateSlotStatus(String slotId, String status) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/slots/$slotId/status',
      data: {'status': status},
      headers: headers,
    );
  }

  // --- Chat APIs ---

  Future<List<ChatRoomModel>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/chats/rooms',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            ChatRoomModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<ChatRoomModel> createChatRoom(CreateChatRoomRequest request) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms',
      data: request.toJson(),
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return ChatRoomModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<List<MessageModel>> getChatMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/messages',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            MessageModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String roomId,
    required String messageText,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/messages',
      data: {'messageText': messageText},
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return MessageModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<void> markChatAsRead(String roomId) async {
    final headers = await _authHeaders();

    await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/chats/rooms/$roomId/read',
      headers: headers,
    );
  }

  // --- User Profile APIs ---

  Future<UserAuthData?> getUserProfile() async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/users/profile',
      headers: headers,
    );

    if (response.data == null) return null;

    final data = response.data!['data'] ?? response.data;
    if (data is! Map<String, dynamic>) return null;

    return UserAuthData.fromJson(data);
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final payload = <String, dynamic>{};
    if (fullName != null) payload['fullName'] = fullName;
    if (phone != null) payload['phone'] = phone;
    if (avatarUrl != null) payload['avatarUrl'] = avatarUrl;

    if (payload.isEmpty) return false;

    try {
      final response = await put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/users/profile',
        data: payload,
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // --- Review APIs ---

  Future<ReviewListResponse> getReviewsByVenue({
    required String venueId,
    int page = 1,
    int pageSize = 5,
  }) async {
    final headers = await _authHeaders();
    final response = await get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/venue/$venueId',
      params: {
        'id': venueId,
        'page': page,
        'pageSize': pageSize,
      },
      headers: headers,
    );

    if (response.data == null) {
      return ReviewListResponse(
        reviews: const [],
        totalCount: 0,
        averageRating: 0,
        page: page,
        pageSize: pageSize,
      );
    }

    final payload = response.data!['data'] ?? response.data;
    if (payload is! Map<String, dynamic>) {
      return ReviewListResponse(
        reviews: const [],
        totalCount: 0,
        averageRating: 0,
        page: page,
        pageSize: pageSize,
      );
    }

    return ReviewListResponse.fromJson(payload);
  }

  Future<ReviewModel> createReview({
    required String venueId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews',
      data: {
        'venueId': venueId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      },
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return ReviewModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<List<ReviewModel>> getMyReviews() async {
    final headers = await _authHeaders();
    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/reviews/my-reviews',
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);

    return list
        .map((json) =>
            ReviewModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/$reviewId',
      data: {
        'rating': rating,
        'comment': comment,
      },
      headers: headers,
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return ReviewModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<void> deleteReview(String reviewId) async {
    final headers = await _authHeaders();
    await delete<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/reviews/$reviewId',
      headers: headers,
    );
  }

  // --- Notification APIs ---

  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'unreadOnly': unreadOnly,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/notifications',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final list = _extractList(response.data);
    return list
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final headers = await _authHeaders();

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/notifications/unread-count',
      headers: headers,
    );

    if (response.data == null) return 0;

    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('count')) {
        return data['count'] as int? ?? 0;
      }
    }

    if (response.data is int) {
      return response.data as int;
    }

    return 0;
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final headers = await _authHeaders();

    try {
      final response = await put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/notifications/$notificationId/read',
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead() async {
    final headers = await _authHeaders();

    try {
      final response = await put<Map<String, dynamic>>(
        '${Env.baseUrl}/api/v1/notifications/read-all',
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
