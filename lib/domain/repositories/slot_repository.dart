import 'package:exe101/data/remote/slot_api_service.dart';

/// Thin wrapper so controllers do not depend on a concrete remote service.
class SlotRepository {
  final SlotApiService slotApiService;

  SlotRepository({required this.slotApiService});

  Future<bool> unlockSlot(String slotId) {
    return slotApiService.unlockSlot(slotId);
  }
}
