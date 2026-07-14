import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/field_detail_controller.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_detail_error_state.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_detail_header_card.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_detail_info_cards.dart';
import 'package:exe101/presentation/features/owner/view/field/widgets/field_slot_management_card.dart';
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
          'Chi tiết sân',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.isLoading.value
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
                    onPressed: controller.reload,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return FieldDetailErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.reload,
          );
        }

        final field = controller.field.value;
        if (field == null) {
          return const Center(child: Text('Không có thông tin sân'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldDetailHeaderCard(field: field),
              const SizedBox(height: 16),
              Obx(
                () => FieldDetailStatusCard(
                  field: controller.field.value ?? field,
                  isToggling: controller.isToggling.value,
                  onToggle: controller.toggleFieldStatus,
                ),
              ),
              const SizedBox(height: 16),
              FieldDescriptionCard(field: field),
              if (field.description?.isNotEmpty == true)
                const SizedBox(height: 16),
              FieldAmenitiesCard(field: field),
              if ((field.amenities ?? const <String>[]).isNotEmpty)
                const SizedBox(height: 16),
              FieldImagesSummaryCard(field: field),
              const SizedBox(height: 24),
              FieldSlotManagementCard(field: field),
            ],
          ),
        );
      }),
    );
  }
}
