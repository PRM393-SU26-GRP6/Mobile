import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/empty_slots_state.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlotsListTab extends StatelessWidget {
  final SlotManagementController controller;
  final VoidCallback onSwitchToCreate;

  const SlotsListTab({
    super.key,
    required this.controller,
    required this.onSwitchToCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.slots.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }
      if (controller.slots.isEmpty) {
        return EmptySlotsState(onCreateTap: onSwitchToCreate);
      }
      return RefreshIndicator(
        onRefresh: () => controller.loadSlots(),
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.slots.length,
          itemBuilder: (context, index) {
            return SlotCard(slot: controller.slots[index]);
          },
        ),
      );
    });
  }
}
