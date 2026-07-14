import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/add_field_amenities_section.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/add_field_submit_section.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/created_fields_bar.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/exit_confirmation_dialog.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_info_section.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_type_section.dart';
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
        title: Obx(
          () => Text(
            'Thêm sân - ${controller.venueName.value}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => showExitConfirmationDialog(context, controller),
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
                    FieldInfoSection(
                      nameController: controller.nameController,
                      descController: controller.descController,
                    ),
                    const SizedBox(height: 24),
                    Obx(
                      () => FieldTypeSection(
                        selectedType: controller.selectedFieldType.value,
                        onTypeChanged: controller.setFieldType,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SlotPricingNotice(),
                    const SizedBox(height: 24),
                    _SectionTitle('Tiện nghi'),
                    const SizedBox(height: 12),
                    AddFieldAmenitiesSection(controller: controller),
                    const SizedBox(height: 32),
                    AddFieldSubmitSection(controller: controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            CreatedFieldsBar(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
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
}

class _SlotPricingNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Giá tiền được cấu hình theo từng slot sau khi tạo sân.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
