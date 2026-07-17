import 'package:exe101/data/remote/schedule/slot_api_service.dart';
import 'package:exe101/data/remote/schedule/slot_schedule_api_service.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bookable slots require persisted id, available status and slot price',
      () async {
    const date = '2026-07-17';
    final scheduleService = _FakeSlotScheduleApiService([
      _slot('persisted', date, 150000, 'Available'),
      _slot('', date, 150000, 'Available'),
      _slot('zero-price', date, 0, 'Available'),
      _slot('booked', date, 160000, 'Booked'),
    ]);
    final repository = SlotRepository(
      slotApiService: _FakeSlotApiService(),
      slotScheduleApiService: scheduleService,
    );

    final result = await repository.getBookableSlots(
      fieldId: 'field-1',
      date: date,
    );

    expect(result.map((slot) => slot.slotId), ['persisted']);
    expect(scheduleService.requests, [('field-1', date)]);
  });
}

TimeSlotDto _slot(String id, String date, double price, String status) {
  return TimeSlotDto(
    slotId: id,
    fieldId: 'field-1',
    startTime: '09:00',
    endTime: '10:00',
    selectedDate: date,
    price: price,
    slotStatus: status,
  );
}

class _FakeSlotScheduleApiService implements SlotScheduleApiService {
  _FakeSlotScheduleApiService(this.slots);

  final List<TimeSlotDto> slots;
  final List<(String, String)> requests = [];

  @override
  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) async {
    requests.add((fieldId, date));
    return slots;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSlotApiService implements SlotApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
