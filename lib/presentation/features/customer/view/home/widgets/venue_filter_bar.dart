import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueFilterBar extends StatelessWidget {
  final VenueController controller;

  const VenueFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: controller.search,
            decoration: InputDecoration(
              hintText: 'Tìm tên cụm sân hoặc địa chỉ',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.secondary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Obx(() {
          if (controller.allAmenities.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.allAmenities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final amenity = controller.allAmenities[index];
                final id = amenity.id ?? '';
                final selected = controller.selectedAmenityIds.contains(id);
                return FilterChip(
                  selected: selected,
                  label: Text(amenity.amenityName ?? 'Tiện ích'),
                  onSelected: id.isEmpty
                      ? null
                      : (_) => controller.toggleAmenityFilter(id),
                );
              },
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }
}
