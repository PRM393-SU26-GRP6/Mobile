import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    required this.slots,
    required this.cart,
    required this.activeField,
    required this.date,
    required this.onToggleSlot,
    super.key,
  });

  final List<SlotInfo> slots;
  final List<CartItem> cart;
  final FieldInfo activeField;
  final String date;
  final void Function(SlotInfo slot, String date) onToggleSlot;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const BookingEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'Chưa có slot',
        message: 'Sân này chưa có khung giờ cho ngày đã chọn.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final slot = slots[index];
        final id = '${activeField.id}-$date-${slot.id}';
        final selected = cart.any((item) => item.id == id);
        return SlotButton(
          slot: slot,
          selected: selected,
          onTap: () => onToggleSlot(slot, date),
        );
      },
    );
  }
}

class SlotButton extends StatelessWidget {
  const SlotButton({
    required this.slot,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final SlotInfo slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = slot.status != SlotStatus.available;
    final color = selected
        ? bookingPrimary
        : disabled
        ? const Color(0xFFE6ECE8)
        : Colors.white;
    final textColor = selected
        ? Colors.white
        : disabled
        ? Colors.grey
        : bookingText;
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? bookingPrimary : bookingLine),
        ),
        child: Text(
          slot.time.split(' - ').first,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
