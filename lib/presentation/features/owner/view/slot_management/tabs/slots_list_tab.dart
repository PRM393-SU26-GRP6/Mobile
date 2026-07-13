import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_selection_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/empty_slots_state.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_card.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_selection_toolbar.dart';
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
    final selectionController = Get.find<SlotSelectionController>();
    final actionsController = Get.find<SlotActionsController>();

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
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            if (selectionController.isSelecting)
              SlotSelectionToolbar(
                selectedCount: selectionController.selectedCount,
                onSelectAll: () => selectionController.selectAll(
                  controller.slots.map((slot) => slot.slotId),
                ),
                onDelete: () => _confirmDeleteSelected(
                  context,
                  selectionController,
                  actionsController,
                ),
                onClear: selectionController.clear,
              ),
            ...controller.slots.map((slot) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Obx(
                  () => SlotCard(
                    slot: slot,
                    selectionMode: selectionController.isSelecting,
                    isSelected: selectionController.isSelected(slot.slotId),
                    onSelectedChanged: (_) =>
                        selectionController.toggle(slot.slotId),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Future<void> _confirmDeleteSelected(
    BuildContext context,
    SlotSelectionController selectionController,
    SlotActionsController actionsController,
  ) async {
    final selectedIds = selectionController.selectedSlotIds.toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa slots da chon?'),
        content: Text('Ban dang chon ${selectedIds.length} slot.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final deletedCount = await actionsController.deleteSlots(selectedIds);
    if (deletedCount > 0) {
      selectionController.clear();
      await controller.loadSlots();
    }
  }
}
