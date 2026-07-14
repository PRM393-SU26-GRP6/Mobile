import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_field_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueFieldSection extends StatelessWidget {
  const VenueFieldSection({required this.controller, super.key});

  final VenueDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chọn sân',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Obx(
                () => controller.isLoadingFields.value
                    ? const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingFields.value) {
              return const SizedBox(height: 80);
            }
            if (controller.fields.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Không có sân con nào',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return Column(
              children: controller.fields
                  .map(
                    (field) => Obx(
                      () => VenueFieldCard(
                        field: field,
                        isSelected:
                            controller.selectedField.value?.id == field.id,
                        rating: controller.ratingFor(field.id),
                        onLoadRating: () =>
                            controller.loadFieldAverageRating(field.id),
                        onTap: () => controller.selectField(field),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
