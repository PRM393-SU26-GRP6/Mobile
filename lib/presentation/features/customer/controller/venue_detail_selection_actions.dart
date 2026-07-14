part of 'venue_detail_controller.dart';

extension VenueDetailSelectionActions on VenueDetailController {
  Future<void> loadSlots(String fieldId) async {
    try {
      isLoadingSlots.value = true;
      error.value = '';
      timeSlots.clear();
      availableSlotDates.clear();
      selectedSlotIds.clear();

      availableSlotDates.assignAll(_nextBookingDates());
      selectedDate.value = availableSlotDates.firstOrNull;

      final date = selectedDate.value;
      if (date != null) {
        final slots = await slotRepository.getBookableSlots(
          fieldId: fieldId,
          date: _formatDate(date),
        );
        timeSlots.assignAll(slots);
      }
    } catch (_) {
      error.value = 'Không thể tải khung giờ';
      timeSlots.clear();
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectField(FootballFieldDto field) {
    clearSelectedSlots();
    selectedField.value = field;
    selectedDate.value = null;
    availableSlotDates.clear();
    timeSlots.clear();
    loadSlots(field.id);
  }

  Future<void> selectDate(DateTime date) async {
    final field = selectedField.value;
    if (field == null || selectedDate.value == date) return;

    clearSelectedSlots();
    selectedDate.value = date;
    await _loadAvailableSlots(field.id, date);
  }

  Future<void> toggleSlot(String selectionKey) async {
    final slot = timeSlots.firstWhereOrNull(
      (item) => item.selectionKey == selectionKey,
    );
    if (slot == null) return;

    if (slot.slotId.isNotEmpty && selectedSlotIds.contains(slot.slotId)) {
      selectedSlotIds.remove(slot.slotId);
      await slotRepository.unlockSlot(slot.slotId);
      return;
    }

    final field = selectedField.value;
    if (field == null || !slot.isAvailable) return;
    if (lockingSlotIds.contains(selectionKey)) return;

    lockingSlotIds.add(selectionKey);
    try {
      final result = await slotRepository.lockSlot(
        slotId: slot.slotId,
        fieldId: field.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
        selectedDate: slot.selectedDate,
      );
      final index = timeSlots.indexWhere(
        (item) => item.selectionKey == selectionKey,
      );
      if (index >= 0) timeSlots[index] = slot.copyWith(slotId: result.slotId);
      selectedSlotIds.add(result.slotId);
    } catch (_) {
      Get.snackbar(
        'Không thể giữ chỗ',
        'Khung giờ vừa được người khác chọn. Danh sách đã được cập nhật.',
        snackPosition: SnackPosition.BOTTOM,
      );
      final date = selectedDate.value;
      if (date != null) await _loadAvailableSlots(field.id, date);
    } finally {
      lockingSlotIds.remove(selectionKey);
    }
  }

  List<DateTime> get availableDates => availableSlotDates;

  List<DateTime> _nextBookingDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(14, (offset) => today.add(Duration(days: offset)));
  }

  List<TimeSlotDto> get slotsForSelectedDate {
    final date = selectedDate.value;
    if (date == null) return const [];
    final selectedDateString = _formatDate(date);
    return timeSlots
        .where(
          (slot) => slot.isAvailable && slot.selectedDate == selectedDateString,
        )
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

  Future<void> _loadAvailableSlots(String fieldId, DateTime date) async {
    try {
      isLoadingSlots.value = true;
      error.value = '';
      final slots = await slotRepository.getBookableSlots(
        fieldId: fieldId,
        date: _formatDate(date),
      );
      timeSlots.assignAll(slots);
    } catch (_) {
      timeSlots.clear();
      error.value = 'Không thể tải khung giờ trống';
    } finally {
      isLoadingSlots.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
