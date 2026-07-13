import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:get/get.dart';

enum SlotSortOrder {
  newest,
  oldest,
  timeAscending,
  priceAscending,
  priceDescending
}

class SlotFilterController extends GetxController {
  final query = ''.obs;
  final status = 'All'.obs;
  final sortOrder = SlotSortOrder.newest.obs;

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      status.value != 'All' ||
      sortOrder.value != SlotSortOrder.newest;

  List<TimeSlotDto> apply(Iterable<TimeSlotDto> source) {
    final normalizedQuery = query.value.trim().toLowerCase();
    final result = source.where((slot) {
      final matchesQuery = normalizedQuery.isEmpty ||
          slot.timeRange.toLowerCase().contains(normalizedQuery) ||
          slot.selectedDate.toLowerCase().contains(normalizedQuery) ||
          (slot.slotStatus ?? '').toLowerCase().contains(normalizedQuery);
      final matchesStatus = status.value == 'All' ||
          (slot.slotStatus ?? 'Available').toLowerCase() ==
              status.value.toLowerCase();
      return matchesQuery && matchesStatus;
    }).toList();

    result.sort((a, b) {
      switch (sortOrder.value) {
        case SlotSortOrder.oldest:
          return _dateOf(a).compareTo(_dateOf(b));
        case SlotSortOrder.timeAscending:
          final dateCompare = _dateOf(a).compareTo(_dateOf(b));
          return dateCompare != 0
              ? dateCompare
              : a.startTime.compareTo(b.startTime);
        case SlotSortOrder.priceAscending:
          return a.price.compareTo(b.price);
        case SlotSortOrder.priceDescending:
          return b.price.compareTo(a.price);
        case SlotSortOrder.newest:
          return _dateOf(b).compareTo(_dateOf(a));
      }
    });
    return result;
  }

  void clear() {
    query.value = '';
    status.value = 'All';
    sortOrder.value = SlotSortOrder.newest;
  }

  DateTime _dateOf(TimeSlotDto slot) =>
      DateTime.tryParse(slot.selectedDate) ?? slot.createdAt ?? DateTime(1970);
}
