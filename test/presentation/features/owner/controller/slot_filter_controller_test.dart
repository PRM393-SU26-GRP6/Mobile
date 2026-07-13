import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_filter_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final slots = [
    TimeSlotDto(
      slotId: 'old',
      fieldId: 'field',
      startTime: '07:00',
      endTime: '08:00',
      selectedDate: '2026-07-01',
      price: 100000,
      slotStatus: 'Available',
    ),
    TimeSlotDto(
      slotId: 'new',
      fieldId: 'field',
      startTime: '18:00',
      endTime: '19:00',
      selectedDate: '2026-07-13',
      price: 200000,
      slotStatus: 'Booked',
    ),
  ];

  test('sorts newest slots first by default', () {
    final controller = SlotFilterController();

    expect(controller.apply(slots).map((slot) => slot.slotId), ['new', 'old']);
  });

  test('filters slots by query and status', () {
    final controller = SlotFilterController()
      ..query.value = '18:00'
      ..status.value = 'Booked';

    expect(controller.apply(slots).map((slot) => slot.slotId), ['new']);
  });
}
