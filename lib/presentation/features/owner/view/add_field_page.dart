import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFieldPage extends StatelessWidget {
  const AddFieldPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddFieldController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Obx(() => Text(
              'Thêm Sân - ${controller.venueName.value}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(context, controller),
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
                    _buildSectionTitle('Thông Tin Sân'),
                    const SizedBox(height: 12),
                    _buildFieldInfoSection(controller),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Loại Sân'),
                    const SizedBox(height: 12),
                    _buildFieldTypeSection(controller),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Khung Giờ & Giá'),
                    const SizedBox(height: 12),
                    _buildPricingSection(controller),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Tiện Nghi'),
                    const SizedBox(height: 12),
                    _buildAmenitiesSection(controller),
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
                                : () => _handleAddField(controller),
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
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Thêm Sân Này',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
            _buildCreatedFieldsBar(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldInfoSection(AddFieldController controller) {
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
          _buildTextField(
            controller: controller.nameController,
            label: 'Tên sân *',
            hint: 'VD: Sân 1, Sân A, Sân Cỏ...',
            prefixIcon: Icons.stadium,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: controller.descController,
            label: 'Mô tả',
            hint: 'VD: Sân cỏ nhân tạo, kích thước tiêu chuẩn...',
            prefixIcon: Icons.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldTypeSection(AddFieldController controller) {
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
      child: Obx(() => Row(
            children: controller.fieldTypes.map((type) {
              final isSelected = controller.selectedFieldType.value == type['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setFieldType(type['value']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.inputBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          type['icon']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type['label']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildPricingSection(AddFieldController controller) {
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
          _buildTimeSlotRow(
            context: Get.context!,
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            label: 'Buổi sáng',
            startController: controller.morningStartController,
            endController: controller.morningEndController,
            priceController: controller.morningPriceController,
            timeEditable: false,
          ),
          const Divider(height: 24),
          _buildTimeSlotRow(
            context: Get.context!,
            icon: Icons.wb_cloudy,
            iconColor: Colors.amber,
            label: 'Buổi chiều',
            startController: controller.afternoonStartController,
            endController: controller.afternoonEndController,
            priceController: controller.afternoonPriceController,
            timeEditable: false,
          ),
          const Divider(height: 24),
          _buildTimeSlotRow(
            context: Get.context!,
            icon: Icons.nightlight_round,
            iconColor: Colors.indigo,
            label: 'Buổi tối',
            startController: controller.eveningStartController,
            endController: controller.eveningEndController,
            priceController: controller.eveningPriceController,
            timeEditable: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController startController,
    required TextEditingController endController,
    required TextEditingController priceController,
    required bool timeEditable,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${startController.text} - ${endController.text}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Giá (VNĐ)',
                  suffixText: 'VNĐ',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(AddFieldController controller) {
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
      child: Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.amenityOptions.map((amenity) {
              final isSelected = controller.isAmenitySelected(amenity['id']!);
              return GestureDetector(
                onTap: () => controller.toggleAmenity(amenity['id']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.inputBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(amenity['icon']!),
                      const SizedBox(width: 6),
                      Text(
                        amenity['name']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildCreatedFieldsBar(AddFieldController controller) {
    return Obx(() {
      if (controller.createdFields.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã thêm ${controller.createdFields.length} sân',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        controller.createdFields.map((f) => f.fieldName ?? 'Sân').join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showFinishDialog(controller),
                  child: const Text(
                    'Xong',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.resetForm();
                  Get.snackbar(
                    'Thành công',
                    'Form đã được reset, bạn có thể thêm sân tiếp',
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    colorText: AppColors.primary,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm Sân Khác'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.secondary,
      ),
    );
  }

  Future<void> _handleAddField(AddFieldController controller) async {
    final field = await controller.createField();

    if (field != null) {
      Get.snackbar(
        'Thành công',
        'Đã thêm sân "${field.fieldName}"',
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        colorText: AppColors.primary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 10,
      );
    }
  }

  void _showExitConfirmation(BuildContext context, AddFieldController controller) {
    if (controller.createdFields.isEmpty) {
      Get.until((route) => route.settings.name == AppPages.ownerHome || route.isFirst);
      _refreshOwnerHome();
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Thoát?'),
        content: Text(
          'Bạn đã thêm ${controller.createdFields.length} sân. Bạn có muốn thoát không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.until((route) => route.settings.name == AppPages.ownerHome || route.isFirst);
              _refreshOwnerHome();
            },
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  void _refreshOwnerHome() {
    if (Get.isRegistered<OwnerHomeController>()) {
      Get.find<OwnerHomeController>().refreshAll();
    }
  }

  void _showFinishDialog(AddFieldController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hoàn Thành'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn đã tạo thành công:'),
            const SizedBox(height: 12),
            ...controller.createdFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(field.fieldName ?? 'Sân'),
                    ],
                  ),
                )),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              Get.until((route) => route.settings.name == AppPages.ownerHome || route.isFirst);
              _refreshOwnerHome();
            },
            child: const Text('Về Trang Quản Lý'),
          ),
        ],
      ),
    );
  }
}
