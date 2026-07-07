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

  final morningStartController = TextEditingController();
  final morningEndController = TextEditingController();
  final morningPriceController = TextEditingController();

  final afternoonStartController = TextEditingController();
  final afternoonEndController = TextEditingController();
  final afternoonPriceController = TextEditingController();

  final eveningStartController = TextEditingController();
  final eveningEndController = TextEditingController();
  final eveningPriceController = TextEditingController();

  final selectedFieldType = 'FiveASide'.obs;
  final selectedAmenities = <String>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final createdFields = <FieldModel>[].obs;

  final List<Map<String, String>> fieldTypes = [
    {'value': 'FiveASide', 'label': 'Sân 5 người', 'icon': '⬢'},
    {'value': 'SevenASide', 'label': 'Sân 7 người', 'icon': '⬡'},
    {'value': 'ElevenASide', 'label': 'Sân 11 người', 'icon': '⬣'},
  ];

  final List<Map<String, String>> amenityOptions = [
    {'id': 'parking', 'name': 'Bãi đỗ xe', 'icon': '🅿️'},
    {'id': 'wifi', 'name': 'Wifi miễn phí', 'icon': '📶'},
    {'id': 'toilet', 'name': 'Nhà vệ sinh', 'icon': '🚻'},
    {'id': 'changing_room', 'name': 'Phòng thay đồ', 'icon': '👕'},
    {'id': 'canteen', 'name': 'Căng tin', 'icon': '🍔'},
    {'id': 'lighting', 'name': 'Đèn chiếu sáng', 'icon': '💡'},
    {'id': 'grass', 'name': 'Cỏ nhân tạo', 'icon': '🌿'},
    {'id': 'air_conditioner', 'name': 'Điều hòa', 'icon': '❄️'},
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      venueId.value = Get.arguments['venueId'] ?? '';
      venueName.value = Get.arguments['venueName'] ?? '';
    }
    _setDefaultTimeSlots();
  }

  void _setDefaultTimeSlots() {
    morningStartController.text = '06:00';
    morningEndController.text = '12:00';
    morningPriceController.text = '';

    afternoonStartController.text = '12:00';
    afternoonEndController.text = '18:00';
    afternoonPriceController.text = '';

    eveningStartController.text = '18:00';
    eveningEndController.text = '22:00';
    eveningPriceController.text = '';
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

    final hasMorningPrice = morningPriceController.text.trim().isNotEmpty;
    final hasAfternoonPrice = afternoonPriceController.text.trim().isNotEmpty;
    final hasEveningPrice = eveningPriceController.text.trim().isNotEmpty;

    if (!hasMorningPrice && !hasAfternoonPrice && !hasEveningPrice) {
      return 'Vui lòng nhập ít nhất một mức giá';
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

    if (venueId.value.isEmpty) {
      errorMessage.value = 'Không tìm thấy thông tin sân bóng';
      return null;
    }

    isLoading.value = true;

    try {
      double? priceMorning;
      double? priceAfternoon;
      double? priceEvening;

      if (morningPriceController.text.trim().isNotEmpty) {
        priceMorning = double.tryParse(morningPriceController.text.trim());
      }
      if (afternoonPriceController.text.trim().isNotEmpty) {
        priceAfternoon = double.tryParse(afternoonPriceController.text.trim());
      }
      if (eveningPriceController.text.trim().isNotEmpty) {
        priceEvening = double.tryParse(eveningPriceController.text.trim());
      }

      debugPrint(
          'Creating field: venueId=$venueId, name=${nameController.text.trim()}, type=${selectedFieldType.value}');

      final field = await apiService.createOwnerField(
        venueId: venueId.value,
        fieldName: nameController.text.trim(),
        fieldType: selectedFieldType.value,
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        priceMorning: priceMorning,
        priceAfternoon: priceAfternoon,
        priceEvening: priceEvening,
        amenities:
            selectedAmenities.isNotEmpty ? selectedAmenities.toList() : null,
      );

      debugPrint('Field created successfully: ${field.fieldName}');

      if (field.id != null && field.id!.isNotEmpty) {
        createdFields.add(field);
        isLoading.value = false;
        return field;
      } else {
        errorMessage.value = 'Dữ liệu trả về không hợp lệ';
        isLoading.value = false;
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating field: $e\n$stackTrace');
      isLoading.value = false;
      errorMessage.value = 'Lỗi: ${e.toString()}';
      return null;
    }
  }

  void resetForm() {
    nameController.clear();
    descController.clear();
    selectedFieldType.value = 'FiveASide';
    selectedAmenities.clear();
    morningPriceController.clear();
    afternoonPriceController.clear();
    eveningPriceController.clear();
    errorMessage.value = '';
    _setDefaultTimeSlots();
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    morningStartController.dispose();
    morningEndController.dispose();
    morningPriceController.dispose();
    afternoonStartController.dispose();
    afternoonEndController.dispose();
    afternoonPriceController.dispose();
    eveningStartController.dispose();
    eveningEndController.dispose();
    eveningPriceController.dispose();
    super.onClose();
  }
}
