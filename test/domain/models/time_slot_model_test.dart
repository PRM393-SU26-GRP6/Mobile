import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeSlotDto.fromAvailableSlotJson', () {
    test('adapts virtual SlotForDateDto without a persisted slot id', () {
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
      expect(slot.selectionKey, 'field-1|2026-07-15|09:00|10:00');
    });

    test('uses the real id after the virtual slot is locked', () {
      final virtualSlot = TimeSlotDto.fromAvailableSlotJson(
        {
          'startTimeOfDay': '09:00',
          'endTimeOfDay': '10:00',
          'price': 120000,
        },
        fieldId: 'field-1',
        selectedDate: '2026-07-15',
      );

      final lockedSlot = virtualSlot.copyWith(slotId: 'real-slot-id');

      expect(lockedSlot.slotId, 'real-slot-id');
      expect(lockedSlot.selectionKey, 'real-slot-id');
    });
  });
}
