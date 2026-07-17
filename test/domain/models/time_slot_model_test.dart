import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeSlotDto.fromAvailableSlotJson', () {
    test('does not create a selectable key without a persisted slot id', () {
      final slot = TimeSlotDto.fromAvailableSlotJson(
        {
          'slotId': null,
          'startTime': '2026-07-15T09:00:00Z',
          'endTime': '2026-07-15T10:00:00Z',
          'startTimeOfDay': '09:00',
          'endTimeOfDay': '10:00',
          'price': 120000,
          'slotStatus': 'Available',
        },
        fieldId: 'field-1',
        selectedDate: '2026-07-15',
      );

      expect(slot.slotId, isEmpty);
      expect(slot.timeRange, '09:00 - 10:00');
      expect(slot.isAvailable, isTrue);
      expect(slot.selectionKey, isEmpty);
    });

    test('uses the persisted slot id as the selection key', () {
      final slot = TimeSlotDto.fromAvailableSlotJson(
        {
          'slotId': 'real-slot-id',
          'startTimeOfDay': '09:00',
          'endTimeOfDay': '10:00',
          'price': 120000,
        },
        fieldId: 'field-1',
        selectedDate: '2026-07-15',
      );

      expect(slot.slotId, 'real-slot-id');
      expect(slot.selectionKey, 'real-slot-id');
    });
  });
}
