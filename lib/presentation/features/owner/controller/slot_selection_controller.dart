import 'package:get/get.dart';

class SlotSelectionController extends GetxController {
  final selectedSlotIds = <String>{}.obs;

  bool get isSelecting => selectedSlotIds.isNotEmpty;
  int get selectedCount => selectedSlotIds.length;

  bool isSelected(String slotId) {
    return selectedSlotIds.contains(slotId);
  }

  void toggle(String slotId) {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);
    } else {
      selectedSlotIds.add(slotId);
    }
  }

  void selectAll(Iterable<String> slotIds) {
    selectedSlotIds.assignAll(slotIds.where((id) => id.isNotEmpty));
  }

  void clear() {
    selectedSlotIds.clear();
  }
}
