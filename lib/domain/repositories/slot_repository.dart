import 'package:exe101/data/remote/slot_api_service.dart';

/// Thin wrapper so controllers do not depend on a concrete remote service.
class SlotRepository {
  final SlotApiService slotApiService;

  SlotRepository({required this.slotApiService});

  Future<bool> unlockSlot(String slotId) {
    return slotApiService.unlockSlot(slotId);
  }

  Future<bool> lockSlot({
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
