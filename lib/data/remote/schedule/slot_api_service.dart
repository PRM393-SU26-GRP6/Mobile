import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Slot endpoints used outside of the booking/owner flows:
/// - POST /api/v1/slots/{id}/unlock
///
/// The selection flow explicitly locks before checkout; `POST /bookings`
/// accepts locks still owned by the current user. Unlock is required when the
/// user backs out before creating the booking.
class SlotApiService {
  final Dio dio;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyAccessToken = 'access_token';

  SlotApiService(this.dio);

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.read(key: _keyAccessToken);
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  /// POST /api/v1/slots/{id}/unlock
  /// Returns true on 2xx, false on any other status or network error.
  Future<bool> unlockSlot(String slotId) async {
    final headers = await _authHeaders();
    try {
      final response = await dio.post(
        '${Env.baseUrl}/api/v1/slots/$slotId/unlock',
        options: Options(headers: headers),
      );
      final code = response.statusCode ?? 0;
      return code >= 200 && code < 300;
    } on DioException catch (_) {
      // Network / timeout / 4xx-5xx — silently fail; the user can still
      // continue using the app and the server will eventually expire the lock.
      return false;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/v1/slots/lock
  /// Returns the persisted slot ID (including newly generated virtual slots).
  Future<SlotLockResult> lockSlot({
    String? slotId,
    required String fieldId,
    required String startTime,
    required String endTime,
    required String selectedDate,
  }) async {
    final headers = await _authHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/slots/lock',
      data: {
        if (slotId != null && slotId.isNotEmpty) 'slotId': slotId,
        'fieldId': fieldId,
        'startTime': startTime,
        'endTime': endTime,
        'selectedDate': selectedDate,
      },
      options: Options(headers: headers),
    );
    final data = response.data?['data'];
    final lockedSlotId = data is Map ? data['slotId']?.toString() ?? '' : '';
    if (lockedSlotId.isEmpty) {
      throw const FormatException('Lock response is missing slotId');
    }
    return SlotLockResult(
      slotId: lockedSlotId,
      lockedUntil: data is Map
          ? DateTime.tryParse(data['lockedUntil']?.toString() ?? '')
          : null,
    );
  }
}
