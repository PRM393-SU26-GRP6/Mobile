import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFieldController extends GetxController {
  final ApiServiceImpl apiService;

  AddFieldController({required this.apiService});

  final venueId = ''.obs;
  final venueName = ''.obs;
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final selectedFieldType = 'FiveASide'.obs;
  final selectedAmenities = <String>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final createdFields = <FieldModel>[].obs;
  final List<Map<String, String>> amenityOptions = const [
    {'id': 'parking', 'name': 'Bãi đỗ xe'},
    {'id': 'wifi', 'name': 'WiFi miễn phí'},
    {'id': 'toilet', 'name': 'Nhà vệ sinh'},
    {'id': 'changing_room', 'name': 'Phòng thay đồ'},
    {'id': 'canteen', 'name': 'Căng tin'},
    {'id': 'lighting', 'name': 'Đèn chiếu sáng'},
    {'id': 'grass', 'name': 'Cỏ nhân tạo'},
    {'id': 'air_conditioner', 'name': 'Điều hòa'},
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      venueId.value = args['venueId']?.toString() ?? '';
      venueName.value = args['venueName']?.toString() ?? '';
    }
  }

  void setFieldType(String type) {
    selectedFieldType.value = type;
  }

  void toggleAmenity(String amenityId) {
    if (selectedAmenities.contains(amenityId)) {
      selectedAmenities.remove(amenityId);
    } else {
      selectedAmenities.add(amenityId);
    }
  }

  bool isAmenitySelected(String amenityId) {
    return selectedAmenities.contains(amenityId);
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Vui lòng nhập tên sân';
    }
    if (venueId.value.isEmpty) {
      return 'Không tìm thấy thông tin sân bóng';
    }
    return null;
  }

  Future<FieldModel?> createField() async {
    errorMessage.value = '';

    final validationError = validateForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isLoading.value = true;
    try {
      final field = await apiService.createOwnerField(
        venueId: venueId.value,
        fieldName: nameController.text.trim(),
        fieldType: selectedFieldType.value,
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        amenities:
            selectedAmenities.isNotEmpty ? selectedAmenities.toList() : null,
      );

      if (field.id != null && field.id!.isNotEmpty) {
        createdFields.add(field);
        return field;
      }

      errorMessage.value = 'Dữ liệu trả về không hợp lệ';
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error creating field: $e\n$stackTrace');
      errorMessage.value = 'Lỗi: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    nameController.clear();
    descController.clear();
    selectedFieldType.value = 'FiveASide';
    selectedAmenities.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    super.onClose();
  }
}
