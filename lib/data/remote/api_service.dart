import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio);

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

  Future<Response<T>> put<T>(String url,
      {Map<String, dynamic> data = const {}}) async {
    return dio.put(url, data: data);
  }

  Future<Response<T>> delete<T>(String url,
      {Map<String, dynamic> data = const {}}) async {
    return dio.delete(url, data: data);
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

  // --- Token / Role access (public, used by splash & auth controllers) ---

  Future<String?> getAccessToken() => _readToken();

  Future<String?> getUserRole() async {
    return _storage.read(key: _keyUserRole);
  }

  // --- Private helpers ---

  Future<void> _saveUserRole(UserAuthData? user) async {
    if (user?.roles != null && user!.roles!.isNotEmpty) {
      await _storage.write(key: _keyUserRole, value: user.roles!.first);
    }
  }

  Future<void> _clearAuth() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserRole);
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

    final dynamic data = response.data != null
        ? (response.data is Map<String, dynamic> ? response.data!['data'] : response.data)
        : null;
    if (data == null) return [];

    List<dynamic> list = [];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      if (data['items'] is List) {
        list = data['items'] as List;
      } else if (data['data'] is List) {
        list = data['data'] as List;
      } else if (data['results'] is List) {
        list = data['results'] as List;
      } else {
        return [];
      }
    } else {
      return [];
    }

    return list
        .map((json) => VenueModel.fromJson(Map<String, dynamic>.from(json as Map)))
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

    dynamic venueData = response.data!['data'];
    if (venueData == null) {
      venueData = response.data;
    }

    if (venueData is Map<String, dynamic>) {
      return VenueModel.fromJson(venueData);
    }
    return null;
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
    int pageSize = 5,
  }) async {
    final headers = await _authHeaders();
    final params = <String, dynamic>{
      'Page': page,
      'PageSize': pageSize,
    };
    if (status != null && status.isNotEmpty) params['Status'] = status;
    if (from != null && from.isNotEmpty) params['From'] = from;
    if (to != null && to.isNotEmpty) params['To'] = to;

    final response = await get<dynamic>(
      '${Env.baseUrl}/api/v1/bookings/history',
      params: params,
      headers: headers,
    );

    if (response.data == null) return [];

    final responseBody = response.data!;

    List<dynamic> items = [];

    if (responseBody is List) {
      items = responseBody;
    } else if (responseBody is Map<String, dynamic>) {
      final data = responseBody['data'];
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic> && data['items'] is List) {
        items = data['items'] as List;
      }
      if (items.isEmpty && responseBody['items'] is List) {
        items = responseBody['items'] as List;
      }
    }

    return items
        .map((json) => BookingDto.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
