import 'package:exe101/presentation/features/customer/controller/venue_detail_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_slot_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueSlotGrid extends StatelessWidget {
  final VenueDetailController controller;
  const VenueSlotGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slots = controller.slotsForSelectedDate;
      if (slots.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Ng뿯½y n뿯½y ch뿯ƽa c뿯½ khung gi뿯ẽ',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        );
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: slots.map((slot) {
          return Obx(() => VenueSlotChip(
                slot: slot,
                isSelected: controller.selectedSlotIds.contains(slot.slotId),
                onTap: () {
                  if (slot.isAvailable) {
                    controller.toggleSlot(slot.slotId);
                  }
                },
              ));
        }).toList(),
      );
    });
  }
}
