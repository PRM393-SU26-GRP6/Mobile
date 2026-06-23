import 'package:exe101/data/remote/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateFieldController extends GetxController {
  final ApiServiceImpl apiService;

  CreateFieldController({required this.apiService});

  final nameController = TextEditingController();
  final descController = TextEditingController();
  final morningController = TextEditingController();
  final afternoonController = TextEditingController();
  final eveningController = TextEditingController();

  final selectedFieldType = 'FiveASide'.obs;
  final selectedAmenities = <String>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final priceMorning = 0.0.obs;
  final priceAfternoon = 0.0.obs;
  final priceEvening = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
  }

  void _setupListeners() {
    morningController.addListener(_updatePriceMorning);
    afternoonController.addListener(_updatePriceAfternoon);
    eveningController.addListener(_updatePriceEvening);
  }

  void _updatePriceMorning() {
    priceMorning.value = double.tryParse(morningController.text) ?? 0.0;
  }

  void _updatePriceAfternoon() {
    priceAfternoon.value = double.tryParse(afternoonController.text) ?? 0.0;
  }

  void _updatePriceEvening() {
    priceEvening.value = double.tryParse(eveningController.text) ?? 0.0;
  }

  void setFieldType(String type) {
    selectedFieldType.value = type;
  }

  void toggleAmenity(String amenity) {
    if (selectedAmenities.contains(amenity)) {
      selectedAmenities.remove(amenity);
    } else {
      selectedAmenities.add(amenity);
    }
  }

  bool isAmenitySelected(String amenity) {
    return selectedAmenities.contains(amenity);
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Vui lòng nhập tên sân';
    }

    if (priceMorning.value <= 0 && priceAfternoon.value <= 0 && priceEvening.value <= 0) {
      return 'Vui lòng nhập ít nhất một mức giá';
    }

    return null;
  }

  Future<bool> createField({required String venueId}) async {
    errorMessage.value = '';

    final validationError = validateForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      return false;
    }

    isLoading.value = true;

    try {
      await apiService.createField(
        venueId: venueId,
        fieldName: nameController.text.trim(),
        fieldType: selectedFieldType.value,
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        priceMorning: priceMorning.value,
        priceAfternoon: priceAfternoon.value,
        priceEvening: priceEvening.value,
        amenities: selectedAmenities.isNotEmpty ? selectedAmenities.toList() : null,
      );

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Không thể tạo sân. Vui lòng thử lại.';
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descController.dispose();
    morningController.dispose();
    afternoonController.dispose();
    eveningController.dispose();
    super.onClose();
  }
}
