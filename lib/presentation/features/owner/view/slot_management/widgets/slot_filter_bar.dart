import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_filter_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotFilterBar extends StatelessWidget {
  const SlotFilterBar({super.key, required this.controller});

  final SlotFilterController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.query.value = value,
              decoration: InputDecoration(
                hintText: 'Tìm theo giờ, ngày, trạng thái...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.inputBorder),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => Badge(
              isLabelVisible: controller.hasActiveFilters,
              child: IconButton.filledTonal(
                tooltip: 'Bộ lọc',
                onPressed: () => showSlotFilterSheet(context, controller),
                icon: const Icon(Icons.tune),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
