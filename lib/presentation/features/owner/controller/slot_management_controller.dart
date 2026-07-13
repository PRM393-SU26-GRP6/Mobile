import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:get/get.dart';

class SlotManagementController extends GetxController {
  SlotManagementController({required this.apiService});

  final ApiServiceImpl apiService;
  final field = Rxn<FieldModel>();
  final slots = <TimeSlotDto>[].obs;
  final isLoading = false.obs;
  final isCreatingSlots = false.obs;
  final errorMessage = ''.obs;
  final fromDate = Rxn<DateTime>();
  final toDate = Rxn<DateTime>();
  final startTime = '06:00'.obs;
  final endTime = '22:00'.obs;
  final slotDuration = 60.obs;
  final slotPrice = 150000.0.obs;

  String? _fieldId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! Map) return;

    if (args['field'] is FieldModel) {
      field.value = args['field'] as FieldModel;
      _fieldId = field.value!.id;
      _loadData();
      return;
    }

    if (args['fieldId'] is String) {
      _fieldId = args['fieldId'] as String;
      loadFieldDetail(_fieldId!);
    }
  }

  Future<void> loadFieldDetail(String fieldId) async {
    try {
      final result = await apiService.getFieldById(fieldId);
      if (result != null) {
        field.value = result;
        await _loadData();
      }
    } catch (_) {
      errorMessage.value = 'Loi khi tai thong tin san';
    }
  }

  Future<void> loadSlots() async {
    if (_fieldId == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      slots.assignAll(await apiService.getSlotsByField(_fieldId!));
    } catch (_) {
      errorMessage.value = 'Loi khi tai danh sach slot';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSlots() async {
    if (_fieldId == null) return;
    if (fromDate.value == null || toDate.value == null) {
      Get.snackbar('Loi', 'Vui long chon ngay bat dau va ket thuc',
          snackPosition: SnackPosition.TOP);
      return;
    }

    isCreatingSlots.value = true;
    errorMessage.value = '';
    try {
      await apiService.bulkCreateSlots(
        fieldId: _fieldId!,
        slotsDto: BulkCreateSlotsDto(
          fromDate: fromDate.value!,
          toDate: toDate.value!,
          startTime: startTime.value,
          endTime: endTime.value,
          slotDurationMinutes: slotDuration.value,
          price: slotPrice.value,
        ),
      );
      Get.snackbar('Thanh cong', 'Da tao slots thanh cong',
          snackPosition: SnackPosition.TOP);
      await loadSlots();
      fromDate.value = null;
      toDate.value = null;
    } catch (_) {
      errorMessage.value = 'Khong the tao slots';
      Get.snackbar('Loi', errorMessage.value, snackPosition: SnackPosition.TOP);
    } finally {
      isCreatingSlots.value = false;
    }
  }

  List<int> get availableDurations => [30, 45, 60, 90, 120];

  Future<void> _loadData() => loadSlots();
}
