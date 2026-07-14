import 'package:exe101/data/remote/schedule/slot_api_service.dart';
import 'package:exe101/data/remote/schedule/slot_schedule_api_service.dart';
import 'package:exe101/domain/models/time_slot_model.dart';

/// Thin wrapper so controllers do not depend on a concrete remote service.
class SlotRepository {
  final SlotApiService slotApiService;
  final SlotScheduleApiService slotScheduleApiService;

  SlotRepository({
    required this.slotApiService,
    required this.slotScheduleApiService,
  });

  Future<List<TimeSlotDto>> getSlotsByField(String fieldId) {
    return slotScheduleApiService.getSlotsByField(fieldId);
  }

  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) {
    return slotScheduleApiService.getAvailableSlots(
      fieldId: fieldId,
      date: date,
    );
  }

  Future<List<TimeSlotDto>> getBookableSlots({
    required String fieldId,
    required String date,
  }) async {
    final results = await Future.wait([
      getAvailableSlots(fieldId: fieldId, date: date),
      getSlotsByField(fieldId),
    ]);
    return filterBookableSlots(
      availableSlots: results[0],
      persistedSlots: results[1],
      selectedDate: date,
    );
  }

  Future<bool> unlockSlot(String slotId) {
    return slotApiService.unlockSlot(slotId);
  }

  Future<SlotLockResult> lockSlot({
    String? slotId,
    required String fieldId,
    required String startTime,
    required String endTime,
    required String selectedDate,
  }) {
    return slotApiService.lockSlot(
      slotId: slotId,
      fieldId: fieldId,
      startTime: startTime,
      endTime: endTime,
      selectedDate: selectedDate,
    );
  }
}

List<TimeSlotDto> filterBookableSlots({
  required List<TimeSlotDto> availableSlots,
  required List<TimeSlotDto> persistedSlots,
  required String selectedDate,
}) {
  final blockedKeys = persistedSlots
      .where((slot) => slot.selectedDate == selectedDate && !slot.isAvailable)
      .map((slot) => _timeKey(slot.startTime, slot.endTime))
      .toSet();

  return availableSlots.where((slot) {
    final timeKey = _timeKey(slot.startTime, slot.endTime);
    return slot.isAvailable && !blockedKeys.contains(timeKey);
  }).toList();
}

String _timeKey(String startTime, String endTime) {
  String normalize(String value) =>
      value.length >= 5 ? value.substring(0, 5) : value;
  return '${normalize(startTime)}|${normalize(endTime)}';
}
