import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueCreationController extends GetxController {
  final ApiServiceImpl apiService;

  VenueCreationController({required this.apiService});

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();
  final openingHourController = TextEditingController();
  final closingHourController = TextEditingController();
  final latitude = RxnDouble();
  final longitude = RxnDouble();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final createdVenue = Rxn<VenueModel>();

  @override
  void onInit() {
    super.onInit();
    openingHourController.text = '06:00';
    closingHourController.text = '22:00';
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) {
      return 'Vui lòng nhập tên sân bóng';
    }
    if (addressController.text.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }
    return null;
  }

  Future<VenueModel?> createVenue() async {
    errorMessage.value = '';

    final validationError = validateForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isLoading.value = true;

    try {
      final openingHours =
          '${openingHourController.text} - ${closingHourController.text}';

      final venue = await apiService.createVenue(
        venueName: nameController.text.trim(),
        address: addressController.text.trim(),
        description: descController.text.trim().isNotEmpty
            ? descController.text.trim()
            : null,
        openingHours: openingHours,
        phoneContact: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        latitude: latitude.value,
        longitude: longitude.value,
      );

      createdVenue.value = venue;
      isLoading.value = false;
      return venue;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Không thể tạo sân. Vui lòng thử lại.';
      return null;
    }
  }

  void clearForm() {
    nameController.clear();
    addressController.clear();
    descController.clear();
    phoneController.clear();
    openingHourController.text = '06:00';
    closingHourController.text = '22:00';
    createdVenue.value = null;
    errorMessage.value = '';
    latitude.value = null;
    longitude.value = null;
  }

  void setLocation(double newLatitude, double newLongitude) {
    latitude.value = newLatitude;
    longitude.value = newLongitude;
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descController.dispose();
    phoneController.dispose();
    openingHourController.dispose();
    closingHourController.dispose();
    super.onClose();
  }
}
