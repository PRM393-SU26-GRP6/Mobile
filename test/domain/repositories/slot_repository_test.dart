import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters persisted Booked and Locked times from virtual availability',
      () {
    const date = '2026-07-15';
    final available = [
      _slot('virtual-1', date, '09:00', '10:00', 'Available'),
      _slot('virtual-2', date, '10:00', '11:00', 'Available'),
      _slot('virtual-3', date, '11:00', '12:00', 'Available'),
    ];
    final persisted = [
      _slot('booked', date, '09:00:00', '10:00:00', 'Booked'),
      _slot('locked', date, '10:00:00', '11:00:00', 'Locked'),
      _slot('other-date', '2026-07-16', '11:00:00', '12:00:00', 'Booked'),
    ];

    final result = filterBookableSlots(
      availableSlots: available,
      persistedSlots: persisted,
      selectedDate: date,
    );

    expect(result.map((slot) => slot.slotId), ['virtual-3']);
  });
}

TimeSlotDto _slot(
  String id,
  String date,
  String start,
  String end,
  String status,
) {
  return TimeSlotDto(
    slotId: id,
    fieldId: 'field-1',
    startTime: start,
    endTime: end,
    selectedDate: date,
    price: 100000,
    slotStatus: status,
  );
}
