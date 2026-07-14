import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';

/// Slot-schedule endpoints used by the owner slot management flow.
///
/// - GET  /api/v1/slots                  (owner reads persisted slots by field)
/// - GET  /api/v1/slots/available        (customer reads available slots by date)
/// - POST /api/v1/owner/fields/{id}/slots/bulk
/// - GET  /api/v1/owner/fields/{id}/schedule
/// - PUT  /api/v1/owner/fields/{id}/schedule
/// - PUT  /api/v1/owner/slots/{id}/status
///
/// Note: lock/unlock endpoints live in `slot_api_service.dart`,
/// and owner-side slot edit/delete lives in `owner_resource_api_service.dart`.
class SlotScheduleApiService extends BaseApiService {
  SlotScheduleApiService(super.dio);

  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/slots/available',
      queryParameters: {'fieldId': fieldId, 'date': date},
      options: Options(headers: headers),
    );

    return BaseApiService.extractList(response.data)
        .whereType<Map>()
        .map(
          (json) => TimeSlotDto.fromAvailableSlotJson(
            Map<String, dynamic>.from(json),
            fieldId: fieldId,
            selectedDate: date,
          ),
        )
        .toList();
  }

  Future<List<TimeSlotDto>> getSlotsByField(String fieldId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/slots',
      queryParameters: {'fieldId': fieldId},
      options: Options(headers: headers),
    );

    if (response.data != null && response.data!['data'] != null) {
      final list = response.data!['data'];
      if (list is List) {
        return list.map((json) => TimeSlotDto.fromJson(json)).toList();
      }
    }
    return [];
  }

  Future<void> bulkCreateSlots({
    required String fieldId,
    required BulkCreateSlotsDto slotsDto,
  }) async {
    final headers = await authJsonHeaders();
    await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/slots/bulk',
      data: slotsDto.toJson(),
      options: Options(headers: headers),
    );
  }

  Future<List<FieldScheduleDto>> getFieldSchedule(String fieldId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/schedule',
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((e) => FieldScheduleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FieldScheduleDto>> updateFieldSchedule({
    required String fieldId,
    required List<FieldScheduleRowDto> rows,
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/fields/$fieldId/schedule',
      data: {'rows': rows.map((e) => e.toJson()).toList()},
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    return list
        .map((e) => FieldScheduleDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateSlotStatus(String slotId, String status) async {
    final headers = await authJsonHeaders();
    await dio.put<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/owner/slots/$slotId/status',
      data: {'slotStatus': status},
      options: Options(headers: headers),
    );
  }
}
