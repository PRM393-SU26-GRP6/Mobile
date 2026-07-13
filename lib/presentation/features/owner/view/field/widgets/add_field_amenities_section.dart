import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/add_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddFieldAmenitiesSection extends StatelessWidget {
  final AddFieldController controller;

  const AddFieldAmenitiesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
      child: Obx(
        () => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: controller.amenityOptions.map((amenity) {
            final id = amenity['id']!;
            final isSelected = controller.isAmenitySelected(id);
            return FilterChip(
              selected: isSelected,
              label: Text(amenity['name']!),
              avatar: Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.1),
              checkmarkColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
              onSelected: (_) => controller.toggleAmenity(id),
            );
          }).toList(),
        ),
      ),
    );
  }
}
