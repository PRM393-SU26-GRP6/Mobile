import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showEditPriceDialog(FieldModel field) async {
  final morningController = TextEditingController(
    text: field.priceMorning?.toStringAsFixed(0) ?? '',
  );
  final afternoonController = TextEditingController(
    text: field.priceAfternoon?.toStringAsFixed(0) ?? '',
  );
  final eveningController = TextEditingController(
    text: field.priceEvening?.toStringAsFixed(0) ?? '',
  );

  await Get.dialog(
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
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: afternoonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá buổi chiều (12:00-18:00)',
                suffixText: 'đ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: eveningController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá buổi tối (18:00-22:00)',
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

              Get.snackbar(
                'Thành công',
                'Đã cập nhật giá sân',
                snackPosition: SnackPosition.TOP,
              );

              controller.loadFieldDetail(field.id!);
            } catch (e) {
              Get.snackbar(
                'Lỗi',
                'Không thể cập nhật giá sân',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('Lưu'),
        ),
      ],
    ),
  );
}
