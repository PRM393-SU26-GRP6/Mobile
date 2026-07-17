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
    final slots = await getAvailableSlots(fieldId: fieldId, date: date);
    return slots
        .where(
          (slot) =>
              slot.slotId.isNotEmpty && slot.isAvailable && slot.price > 0,
        )
        .toList();
  }

  Future<bool> unlockSlot(String slotId) {
    return slotApiService.unlockSlot(slotId);
  }

  Future<SlotLockResult> lockSlot({
    required String slotId,
  }) {
    return slotApiService.lockSlot(slotId: slotId);
  }
}
