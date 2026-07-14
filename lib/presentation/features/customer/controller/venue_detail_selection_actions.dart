part of 'venue_detail_controller.dart';

extension VenueDetailSelectionActions on VenueDetailController {
  Future<void> loadSlots(String fieldId) async {
    try {
      isLoadingSlots.value = true;
      final result =
          await (apiService as ApiServiceImpl).getSlotsByField(fieldId);
      timeSlots.value = result;
      selectedSlotIds.clear();
      selectedDate.value = availableDates.firstOrNull;
    } catch (_) {
      error.value = 'Không thể tải khung giờ';
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectField(FootballFieldDto field) {
    selectedField.value = field;
    selectedSlotIds.clear();
    selectedDate.value = null;
    timeSlots.clear();
    loadSlots(field.id);
  }

  void selectDate(DateTime date) => selectedDate.value = date;

  Future<void> toggleSlot(String slotId) async {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);
      await slotRepository.unlockSlot(slotId);
      return;
    }

    final slot = timeSlots.firstWhereOrNull((item) => item.slotId == slotId);
    final field = selectedField.value;
    if (slot == null || field == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.accent)),
      barrierDismissible: false,
    );
    final success = await slotRepository.lockSlot(
      slotId: slot.slotId,
      fieldId: field.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      selectedDate: slot.selectedDate,
    );
    if (Get.isDialogOpen == true) Get.back<void>();

    if (success) {
      selectedSlotIds.add(slotId);
    } else {
      Get.snackbar(
        'Không thể giữ chỗ',
        'Khung giờ này đã có người đặt hoặc đang giữ chỗ.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<DateTime> get availableDates {
    final dates = <String, DateTime>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final slot in timeSlots) {
      final parts = slot.selectedDate.split('-');
      if (parts.length != 3) continue;
      final date = DateTime.tryParse(slot.selectedDate);
      if (date == null || date.isBefore(today)) continue;
      dates[slot.selectedDate] = date;
    }
    return dates.values.toList()..sort();
  }

  List<TimeSlotDto> get slotsForSelectedDate {
    final date = selectedDate.value;
    if (date == null) return const [];
    final selectedDateString = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    return timeSlots
        .where((slot) => slot.selectedDate == selectedDateString)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  double get totalPrice => timeSlots
      .where((slot) => selectedSlotIds.contains(slot.slotId))
      .fold(0, (sum, slot) => sum + slot.price);

  void unlockSelectedSlots() {
    if (_unlockDispatched || selectedSlotIds.isEmpty) return;
    _unlockDispatched = true;
    for (final slotId in selectedSlotIds) {
      slotRepository.unlockSlot(slotId);
    }
  }

  void clearSelectedSlots() {
    unlockSelectedSlots();
    selectedSlotIds.clear();
    _unlockDispatched = false;
  }
}
