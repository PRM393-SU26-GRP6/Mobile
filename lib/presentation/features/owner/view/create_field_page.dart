import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/create_field_controller.dart';
import 'package:exe101/presentation/features/owner/view/widgets/amenities_section.dart';
import 'package:exe101/presentation/features/owner/view/widgets/field_info_section.dart';
import 'package:exe101/presentation/features/owner/view/widgets/field_type_section.dart';
import 'package:exe101/presentation/features/owner/view/widgets/pricing_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateFieldPage extends StatelessWidget {
  const CreateFieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateFieldController>();
    final String? venueId = Get.arguments?['venueId'] as String?;

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tạo Sân Mới',
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
                  children: [
                    FieldInfoSection(
                      nameController: controller.nameController,
                      descController: controller.descController,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => FieldTypeSection(
                          selectedType: controller.selectedFieldType.value,
                          onTypeChanged: controller.setFieldType,
                        )),
                    const SizedBox(height: 20),
                    PricingSection(
                      morningController: controller.morningController,
                      afternoonController: controller.afternoonController,
                      eveningController: controller.eveningController,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => AmenitiesSection(
                          selectedAmenities: controller.selectedAmenities.toList(),
                          onToggle: controller.toggleAmenity,
                        )),
                    const SizedBox(height: 24),
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
                                : () => _handleSubmit(context, controller, venueId),
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
                                    color: AppColors.primary.withValues(alpha: 0.3),
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
                                        'Tạo Sân',
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

  Future<void> _handleSubmit(
    BuildContext context,
    CreateFieldController controller,
    String? venueId,
  ) async {
    if (venueId == null || venueId.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Không tìm thấy thông tin sân. Vui lòng thử lại.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
      return;
    }

    final success = await controller.createField(venueId: venueId);

    if (success) {
      Get.back(result: true);
      Get.snackbar(
        'Thành Công',
        'Sân bóng đã được tạo thành công!',
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: AppColors.primary),
      );
    }
  }
}
