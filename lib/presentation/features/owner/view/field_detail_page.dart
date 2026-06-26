import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FieldDetailPage extends StatelessWidget {
  const FieldDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FieldDetailController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chi Tiết Sân',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    if (Get.arguments != null && Get.arguments['fieldId'] != null) {
                      controller.loadFieldDetail(Get.arguments['fieldId']);
                    }
                  },
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (Get.arguments != null && Get.arguments['fieldId'] != null) {
                        controller.loadFieldDetail(Get.arguments['fieldId']);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final field = controller.field.value;
        if (field == null) {
          return const Center(
            child: Text('Không có thông tin sân'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldHeader(field),
              const SizedBox(height: 16),
              _buildStatusCard(field, controller),
              const SizedBox(height: 16),
              _buildPriceCard(field),
              if (field.description != null && field.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDescriptionCard(field),
              ],
              if (field.amenities != null && field.amenities!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildAmenitiesCard(field),
              ],
              const SizedBox(height: 24),
              _buildSlotManagementButton(field),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFieldHeader(FieldModel field) {
    final fieldTypeLabel = FieldModel.fieldTypeLabels[field.fieldType] ?? field.fieldType ?? 'Sân';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.fieldName ?? 'Sân không tên',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    fieldTypeLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(FieldModel field, FieldDetailController controller) {
    final isActive = field.isActive ?? false;

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái hoạt động',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive ? 'Đang hoạt động' : 'Tạm tắt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Obx(() => Switch(
                value: controller.field.value?.isActive ?? false,
                onChanged: controller.isToggling.value
                    ? null
                    : (value) => controller.toggleFieldStatus(),
                activeThumbColor: AppColors.primary,
              )),
          Obx(() {
            if (controller.isToggling.value) {
              return const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildPriceCard(FieldModel field) {
    final price = field.pricePerHour ??
        (field.priceMorning ??
            (field.priceAfternoon ?? field.priceEvening ?? 0));

    final hasPrice = field.pricePerHour != null ||
        field.priceMorning != null ||
        field.priceAfternoon != null ||
        field.priceEvening != null;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Giá sân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildEditPriceButton(field),
            ],
          ),
          const SizedBox(height: 12),
          if (field.pricePerHour != null && field.pricePerHour! > 0)
            _buildPriceRow('Giá theo giờ', field.pricePerHour!)
          else ...[
            if (field.priceMorning != null && field.priceMorning! > 0)
              _buildPriceRow('Giá buổi sáng (06:00-12:00)', field.priceMorning!),
            if (field.priceAfternoon != null && field.priceAfternoon! > 0)
              _buildPriceRow('Giá buổi chiều (12:00-18:00)', field.priceAfternoon!),
            if (field.priceEvening != null && field.priceEvening! > 0)
              _buildPriceRow('Giá buổi tối (18:00-22:00)', field.priceEvening!),
          ],
          if (!hasPrice || price <= 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chưa có thông tin giá. Vui lòng cập nhật giá sân.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditPriceButton(FieldModel field) {
    return GestureDetector(
      onTap: () => _showEditPriceDialog(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: AppColors.primary, size: 14),
            SizedBox(width: 4),
            Text(
              'Sửa',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPriceDialog(FieldModel field) {
    final morningController = TextEditingController(
      text: field.priceMorning?.toStringAsFixed(0) ?? '',
    );
    final afternoonController = TextEditingController(
      text: field.priceAfternoon?.toStringAsFixed(0) ?? '',
    );
    final eveningController = TextEditingController(
      text: field.priceEvening?.toStringAsFixed(0) ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: const Text('Cập nhật giá sân'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: morningController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá buổi sáng (06:00-12:00)',
                  prefixText: '',
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: afternoonController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá buổi chiều (12:00-18:00)',
                  prefixText: '',
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: eveningController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá buổi tối (18:00-22:00)',
                  prefixText: '',
                  suffixText: 'đ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final controller = Get.find<FieldDetailController>();
              final priceMorning = double.tryParse(morningController.text);
              final priceAfternoon = double.tryParse(afternoonController.text);
              final priceEvening = double.tryParse(eveningController.text);

              Get.back();

              try {
                await controller.apiService.updateField(
                  fieldId: field.id!,
                  priceMorning: priceMorning,
                  priceAfternoon: priceAfternoon,
                  priceEvening: priceEvening,
                );

                Get.snackbar('Thành công', 'Đã cập nhật giá sân',
                    snackPosition: SnackPosition.TOP);

                // Reload field detail
                controller.loadFieldDetail(field.id!);
              } catch (e) {
                Get.snackbar('Lỗi', 'Không thể cập nhật giá sân',
                    snackPosition: SnackPosition.TOP);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${price.toStringAsFixed(0)}đ/giờ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(FieldModel field) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.description, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Mô tả',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            field.description!,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesCard(FieldModel field) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.list_alt, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Tiện ích',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: field.amenities!.map((amenity) {
              final amenityLabel = FieldModel.availableAmenities.contains(amenity)
                  ? amenity
                  : amenity;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  amenityLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotManagementButton(FieldModel field) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/owner/slot-management', arguments: {'field': field});
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Slots',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tạo lịch sân, quản lý khung giờ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
