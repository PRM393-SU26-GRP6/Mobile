import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:get/get.dart';

class FieldDetailController extends GetxController {
  final ApiServiceImpl apiService;

  FieldDetailController({required this.apiService});

  final field = Rxn<FieldModel>();
  final isLoading = false.obs;
  final isToggling = false.obs;
  final errorMessage = ''.obs;

  String? _fieldId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['fieldId'] != null) {
      _fieldId = Get.arguments['fieldId'];
      loadFieldDetail(_fieldId!);
    }
  }

  Future<void> loadFieldDetail(String fieldId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await apiService.getFieldById(fieldId);
      if (result != null) {
        field.value = result;
      } else {
        errorMessage.value = 'Không tìm thấy thông tin sân';
      }
    } catch (e) {
      errorMessage.value = 'Lỗi khi tải thông tin sân: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFieldStatus() async {
    if (field.value == null) return;

    isToggling.value = true;
    try {
      final newStatus = !(field.value!.isActive ?? true);
      await apiService.updateFieldStatus(field.value!.id!, newStatus);

      field.value = FieldModel(
        id: field.value!.id,
        venueId: field.value!.venueId,
        fieldName: field.value!.fieldName,
        description: field.value!.description,
        fieldType: field.value!.fieldType,
        priceMorning: field.value!.priceMorning,
        priceAfternoon: field.value!.priceAfternoon,
        priceEvening: field.value!.priceEvening,
        pricePerHour: field.value!.pricePerHour,
        amenities: field.value!.amenities,
        isActive: newStatus,
        images: field.value!.images,
      );

      // Refresh OwnerHomeController to update the list
      if (Get.isRegistered<OwnerHomeController>()) {
        final ownerController = Get.find<OwnerHomeController>();
        if (ownerController.selectedVenue.value != null) {
          await ownerController
              .loadFields(ownerController.selectedVenue.value!.id);
        }
      }

      Get.snackbar(
        'Thành công',
        newStatus ? 'Sân đã được kích hoạt' : 'Sân đã được tắt',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái sân',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isToggling.value = false;
    }
  }
}
