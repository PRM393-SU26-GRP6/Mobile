import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/presentation/features/owner/controller/slot_actions_controller.dart';
import 'package:exe101/presentation/features/owner/controller/slot_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/slot_management/widgets/slot_edit_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showSlotEditDialog(
  BuildContext context,
  TimeSlotDto slot,
) async {
  final priceController = TextEditingController(text: slot.price.toString());
  final result = await Get.dialog<SlotEditResult>(
    SlotEditContent(slot: slot, priceController: priceController),
  );
  priceController.dispose();
  if (result == null) return;

  final updated = await Get.find<SlotActionsController>().updateSlot(
    slotId: slot.slotId,
    price: result.price,
    status: result.status,
  );
  if (updated && Get.isRegistered<SlotManagementController>()) {
    await Get.find<SlotManagementController>().loadSlots();
  }
}
