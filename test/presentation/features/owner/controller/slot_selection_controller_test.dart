import 'package:exe101/presentation/features/owner/controller/slot_selection_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toggles and clears selected slot ids', () {
    final controller = SlotSelectionController();

    controller.toggle('slot-1');
    controller.toggle('slot-2');

    expect(controller.isSelecting, isTrue);
    expect(controller.selectedCount, 2);
    expect(controller.isSelected('slot-1'), isTrue);

    controller.toggle('slot-1');

    expect(controller.selectedCount, 1);
    expect(controller.isSelected('slot-1'), isFalse);

    controller.clear();

    expect(controller.isSelecting, isFalse);
  });

  test('selectAll ignores empty slot ids', () {
    final controller = SlotSelectionController();

    controller.selectAll(['slot-1', '', 'slot-2']);

    expect(controller.selectedSlotIds, {'slot-1', 'slot-2'});
  });
}
