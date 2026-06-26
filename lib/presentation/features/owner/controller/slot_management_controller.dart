import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:get/get.dart';

class SlotManagementController extends GetxController {
  final ApiServiceImpl apiService;

  SlotManagementController({required this.apiService});

  final field = Rxn<FieldModel>();
  final schedules = <FieldScheduleDto>[].obs;
  final slots = <TimeSlotDto>[].obs;
  final isLoading = false.obs;
  final isCreatingSlots = false.obs;
  final isSavingSchedule = false.obs;
  final errorMessage = ''.obs;

  // Form state
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final startTime = '06:00'.obs;
  final endTime = '22:00'.obs;
  final slotDuration = 60.obs;
  final slotPrice = 150000.0.obs;

  // Schedule edit state
  final editingSchedules = <FieldScheduleRowDto>[].obs;

  String? _fieldId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      if (Get.arguments['field'] != null) {
        field.value = Get.arguments['field'] as FieldModel;
        _fieldId = field.value!.id;
        // Load schedule and slots after setting field
        _loadData();
      } else if (Get.arguments['fieldId'] != null) {
        _fieldId = Get.arguments['fieldId'] as String;
        loadFieldDetail(_fieldId!);
      }
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      loadSchedule(),
      loadSlots(),
    ]);
  }

  Future<void> loadFieldDetail(String fieldId) async {
    try {
      final result = await apiService.getFieldById(fieldId);
      if (result != null) {
        field.value = result;
      }
    } catch (e) {
      errorMessage.value = 'Lỗi khi tải thông tin sân';
    }
  }

  Future<void> loadSchedule() async {
    if (_fieldId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await apiService.getFieldSchedule(_fieldId!);
      schedules.assignAll(result);

      // Initialize editing schedules
      editingSchedules.assignAll(
        result.map((s) => FieldScheduleRowDto(
          dayOfWeek: s.dayOfWeek,
          openTime: s.openTime,
          closeTime: s.closeTime,
          slotDurationMinutes: s.slotDurationMinutes,
          isActive: s.isActive,
        )).toList(),
      );
    } catch (e) {
      errorMessage.value = 'Lỗi khi tải lịch sân';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSlots() async {
    if (_fieldId == null) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await apiService.getSlotsByField(_fieldId!);
      slots.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Lỗi khi tải danh sách slot';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSlots() async {
    if (_fieldId == null) return;
    if (fromDate.value == null || toDate.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn ngày bắt đầu và kết thúc',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCreatingSlots.value = true;
    errorMessage.value = '';

    try {
      final dto = BulkCreateSlotsDto(
        fromDate: fromDate.value!,
        toDate: toDate.value!,
        startTime: startTime.value,
        endTime: endTime.value,
        slotDurationMinutes: slotDuration.value,
        price: slotPrice.value,
      );

      await apiService.bulkCreateSlots(fieldId: _fieldId!, slotsDto: dto);

      Get.snackbar('Thành công', 'Đã tạo slots thành công',
          snackPosition: SnackPosition.BOTTOM);

      // Refresh slots list
      await loadSlots();

      // Reset form
      fromDate.value = null;
      toDate.value = null;
    } catch (e) {
      errorMessage.value = 'Lỗi khi tạo slots: ${e.toString()}';
      Get.snackbar('Lỗi', 'Không thể tạo slots', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCreatingSlots.value = false;
    }
  }

  Future<void> saveSchedule() async {
    if (_fieldId == null) return;

    isSavingSchedule.value = true;
    errorMessage.value = '';

    try {
      await apiService.updateFieldSchedule(
        fieldId: _fieldId!,
        rows: editingSchedules.toList(),
      );

      Get.snackbar('Thành công', 'Đã lưu lịch sân thành công',
          snackPosition: SnackPosition.BOTTOM);

      // Refresh schedule
      await loadSchedule();
    } catch (e) {
      errorMessage.value = 'Lỗi khi lưu lịch sân';
      Get.snackbar('Lỗi', 'Không thể lưu lịch sân', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSavingSchedule.value = false;
    }
  }

  void updateEditingSchedule(int dayIndex, {String? openTime, String? closeTime, int? slotDuration, bool? isActive}) {
    if (dayIndex < 0 || dayIndex >= editingSchedules.length) return;

    final current = editingSchedules[dayIndex];
    editingSchedules[dayIndex] = FieldScheduleRowDto(
      dayOfWeek: current.dayOfWeek,
      openTime: openTime ?? current.openTime,
      closeTime: closeTime ?? current.closeTime,
      slotDurationMinutes: slotDuration ?? current.slotDurationMinutes,
      isActive: isActive ?? current.isActive,
    );
  }

  Future<void> toggleSlotStatus(String slotId, bool isActive) async {
    try {
      final status = isActive ? 'Available' : 'Locked';
      await apiService.updateSlotStatus(slotId, status);
      await loadSlots();

      Get.snackbar(
        'Thành công',
        isActive ? 'Đã mở slot' : 'Đã khóa slot',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái slot',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void setDateRange(DateTime start, DateTime end) {
    fromDate.value = start;
    toDate.value = end;
  }

  List<int> get availableDurations => [30, 45, 60, 90, 120];

  String formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    }
    return '${(price / 1000).toStringAsFixed(0)}K';
  }
}
