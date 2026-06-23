import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:get/get.dart';

class VenueDetailController extends GetxController {
  final ApiService apiService;

  final venue = Rxn<VenueModel>();
  final fields = <FootballFieldDto>[].obs;
  final timeSlots = <TimeSlotDto>[].obs;

  final isLoadingVenue = false.obs;
  final isLoadingFields = false.obs;
  final isLoadingSlots = false.obs;

  final selectedField = Rxn<FootballFieldDto>();
  final selectedDate = Rxn<DateTime>();
  final selectedSlotIds = <String>[].obs;

  final error = ''.obs;

  VenueDetailController({required this.apiService});

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is VenueModel) {
      venue.value = arg;
      loadFields(arg.id);
    } else if (arg is String && arg.isNotEmpty) {
      loadVenue(arg);
    }
  }

  Future<void> loadVenue(String venueId) async {
    try {
      isLoadingVenue.value = true;
      error.value = '';
      final result = await (apiService as ApiServiceImpl).getVenueById(venueId);
      venue.value = result;
      if (result != null) {
        loadFields(result.id);
      }
    } catch (e) {
      error.value = 'Không thể tải thông tin sân: $e';
    } finally {
      isLoadingVenue.value = false;
    }
  }

  Future<void> loadFields(String venueId) async {
    try {
      isLoadingFields.value = true;
      final result = await (apiService as ApiServiceImpl).getFieldsByVenue(venueId);
      fields.value = result;
    } catch (e) {
      fields.clear();
    } finally {
      isLoadingFields.value = false;
    }
  }

  Future<void> loadSlots(String fieldId) async {
    try {
      isLoadingSlots.value = true;
      final result = await (apiService as ApiServiceImpl).getSlotsByField(fieldId);
      timeSlots.value = result;
      selectedSlotIds.clear();
      final dates = availableDates;
      if (dates.isNotEmpty) {
        selectedDate.value = dates.first;
      } else {
        selectedDate.value = null;
      }
    } catch (e) {
      error.value = 'Không thể tải khung giờ: $e';
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

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void toggleSlot(String slotId) {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);
    } else {
      selectedSlotIds.add(slotId);
    }
  }

  List<DateTime> get availableDates {
    final dates = <String, DateTime>{};
    for (final slot in timeSlots) {
      if (slot.selectedDate.isEmpty) continue;
      final parts = slot.selectedDate.split('-');
      if (parts.length != 3) continue;
      try {
        final d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        dates[slot.selectedDate] = d;
      } catch (_) {
        continue;
      }
    }
    final list = dates.values.toList()..sort();
    return list;
  }

  List<TimeSlotDto> get slotsForSelectedDate {
    if (selectedDate.value == null) return [];
    final ymd =
        '${selectedDate.value!.year.toString().padLeft(4, '0')}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';
    final list = timeSlots
        .where((s) => s.selectedDate == ymd)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  double get totalPrice {
    final selectedSlots = timeSlots.where((s) => selectedSlotIds.contains(s.slotId));
    return selectedSlots.fold(0.0, (sum, s) => sum + s.price);
  }
}
