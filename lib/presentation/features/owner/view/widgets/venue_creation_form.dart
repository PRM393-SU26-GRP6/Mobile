import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:exe101/presentation/features/owner/view/shared/venue_location_field.dart';
import 'package:exe101/presentation/features/owner/view/widgets/owner_form_field.dart';
import 'package:exe101/presentation/features/owner/view/widgets/venue_opening_hours_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueCreationForm extends StatelessWidget {
  const VenueCreationForm({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final VenueCreationController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionTitle('Thông tin cơ bản'),
        const SizedBox(height: 12),
        OwnerFormField(
          controller: controller.nameController,
          label: 'Tên sân bóng *',
          hint: 'Ví dụ: Sân bóng Thể thao ABC',
          icon: Icons.stadium,
        ),
        const SizedBox(height: 16),
        OwnerFormField(
          controller: controller.addressController,
          label: 'Địa chỉ *',
          hint: 'Nhập địa chỉ đầy đủ của sân',
          icon: Icons.location_on,
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Obx(
          () => VenueLocationField(
            latitude: controller.latitude.value,
            longitude: controller.longitude.value,
            onTap: () => _pickLocation(context),
          ),
        ),
        const SizedBox(height: 16),
        OwnerFormField(
          controller: controller.phoneController,
          label: 'Số điện thoại liên hệ',
          hint: 'Ví dụ: 0909123456',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Mô tả'),
        const SizedBox(height: 12),
        OwnerFormField(
          controller: controller.descController,
          label: 'Mô tả sân bóng',
          hint: 'Mô tả mặt sân, tiện ích và lưu ý khi đặt sân',
          icon: Icons.description,
          maxLines: 4,
        ),
        const SizedBox(height: 24),
        const _SectionTitle('Giờ mở cửa'),
        const SizedBox(height: 12),
        VenueOpeningHoursField(
          openingController: controller.openingHourController,
          closingController: controller.closingHourController,
        ),
        const SizedBox(height: 24),
        Obx(
          () => controller.errorMessage.value.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => FilledButton(
            onPressed: controller.isLoading.value ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: controller.isLoading.value
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Tiếp tục'),
          ),
        ),
      ],
    );
  }

  Future<void> _pickLocation(BuildContext context) async {
    final result = await pickVenueLocation(
      context,
      latitude: controller.latitude.value,
      longitude: controller.longitude.value,
      address: controller.addressController.text,
    );
    if (result != null) {
      controller.setLocation(result.latitude, result.longitude);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}
