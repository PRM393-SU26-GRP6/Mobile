import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueEditController extends GetxController {
  VenueEditController({required this.apiService});

  final ApiServiceImpl apiService;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();
  final openingHoursController = TextEditingController();
  final phoneController = TextEditingController();
  final latitude = RxnDouble();
  final longitude = RxnDouble();
  final isSaving = false.obs;
  final errorMessage = ''.obs;
  late final VenueModel venue;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is! VenueModel) {
      throw ArgumentError('VenueEditPage requires a VenueModel argument.');
    }
    venue = args;
    nameController.text = venue.venueName ?? '';
    addressController.text = venue.address ?? '';
    descriptionController.text = venue.description ?? '';
    openingHoursController.text = venue.openingHours ?? '';
    phoneController.text = venue.phoneContact ?? '';
    latitude.value = venue.latitude;
    longitude.value = venue.longitude;
  }

  String? validateForm() {
    if (nameController.text.trim().isEmpty) return 'Vui long nhap ten venue.';
    if (addressController.text.trim().isEmpty) return 'Vui long nhap dia chi.';
    return null;
  }

  Future<VenueModel?> save() async {
    final validationError = validateForm();
    if (validationError != null) {
      errorMessage.value = validationError;
      return null;
    }

    isSaving.value = true;
    errorMessage.value = '';
    try {
      return await apiService.updateVenue(
        venueId: venue.id,
        venueName: nameController.text.trim(),
        address: addressController.text.trim(),
        description: descriptionController.text.trim(),
        openingHours: openingHoursController.text.trim(),
        phoneContact: phoneController.text.trim(),
        latitude: latitude.value,
        longitude: longitude.value,
      );
    } catch (_) {
      errorMessage.value = 'Khong the cap nhat venue. Vui long thu lai.';
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  void setLocation(double newLatitude, double newLongitude) {
    latitude.value = newLatitude;
    longitude.value = newLongitude;
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    openingHoursController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
