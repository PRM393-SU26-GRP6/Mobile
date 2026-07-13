import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:exe101/presentation/features/owner/view/shared/venue_location_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueCreationPage extends StatelessWidget {
  const VenueCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueCreationController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tạo Sân Bóng Mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Thông Tin Cơ Bản'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Tên sân bóng *',
                      hint: 'VD: Sân Bóng Thể Thao ABC',
                      prefixIcon: Icons.stadium,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.addressController,
                      label: 'Địa chỉ *',
                      hint: 'VD: 123 Đường Nguyễn Trãi, Quận 1, TP.HCM',
                      prefixIcon: Icons.location_on,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => VenueLocationField(
                        latitude: controller.latitude.value,
                        longitude: controller.longitude.value,
                        onTap: () => _pickLocation(context, controller),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: controller.phoneController,
                      label: 'Số điện thoại liên hệ',
                      hint: 'VD: 0909123456',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Mô Tả'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.descController,
                      label: 'Mô tả sân bóng',
                      hint:
                          'VD: Sân cỏ nhân tạo chất lượng cao, đầy đủ tiện nghi...',
                      prefixIcon: Icons.description,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Giờ Mở Cửa'),
                    const SizedBox(height: 12),
                    _buildOpeningHours(controller),
                    const SizedBox(height: 32),
                    Obx(() {
                      if (controller.errorMessage.value.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  size: 20, color: Colors.red.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : () => _handleSubmit(controller),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.buttonGradientStart,
                                    AppColors.buttonGradientEnd
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Tiếp Tục',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(prefixIcon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOpeningHours(VenueCreationController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Khung giờ hoạt động',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(
                  context: Get.context!,
                  controller: controller.openingHourController,
                  label: 'Mở cửa',
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(
                  context: Get.context!,
                  controller: controller.closingHourController,
                  label: 'Đóng cửa',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
  }) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.parse(controller.text.split(':')[0]),
            minute: int.parse(controller.text.split(':')[1]),
          ),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (time != null) {
          controller.text =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(VenueCreationController controller) async {
    final venue = await controller.createVenue();

    if (venue != null) {
      // Xóa VenueCreationPage khỏi stack và push AddFieldPage
      Get.offNamed(
        AppPages.addField,
        arguments: {
          'venueId': venue.id,
          'venueName': venue.venueName ?? controller.nameController.text,
        },
      );
    }
  }

  Future<void> _pickLocation(
    BuildContext context,
    VenueCreationController controller,
  ) async {
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
