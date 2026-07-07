import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/controller/owner_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Dialog xác nhận thoát khi đã thêm nhiều sân.
Future<void> showExitConfirmationDialog(
  BuildContext context,
  AddFieldController controller,
) async {
  if (controller.createdFields.isEmpty) {
    _exitToOwnerHome();
    return;
  }

  await Get.dialog(
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
            _exitToOwnerHome();
          },
          child: const Text('Thoát'),
        ),
      ],
    ),
  );
}

/// Dialog hoàn thành khi đã tạo các sân.
Future<void> showFinishDialog(AddFieldController controller) async {
  await Get.dialog(
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
                    const Icon(
                      Icons.check,
                      color: AppColors.primary,
                      size: 16,
                    ),
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
            _exitToOwnerHome();
          },
          child: const Text('Về Trang Quản Lý'),
        ),
      ],
    ),
  );
}

void _exitToOwnerHome() {
  Get.until(
    (route) => route.settings.name == AppPages.ownerHome || route.isFirst,
  );
  if (Get.isRegistered<OwnerHomeController>()) {
    Get.find<OwnerHomeController>().refreshAll();
  }
}
