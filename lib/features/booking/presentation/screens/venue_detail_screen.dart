import 'package:flutter/material.dart';

import '../../data/booking_mock_data.dart';
import '../../domain/booking_models.dart';
import '../widgets/booking_ui.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({
    required this.venue,
    required this.selectedField,
    required this.cart,
    required this.onBack,
    required this.onFieldChanged,
    required this.onToggleSlot,
    required this.onGoCart,
    super.key,
  });

  final Venue venue;
  final FieldInfo selectedField;
  final List<CartItem> cart;
  final VoidCallback onBack;
  final ValueChanged<FieldInfo> onFieldChanged;
  final void Function(SlotInfo slot, String date) onToggleSlot;
  final VoidCallback onGoCart;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  String _date = '2026-06-05';

  @override
  Widget build(BuildContext context) {
    final available = bookingSlots.where((slot) => slot.status == SlotStatus.available).length;

    return BookingShell(
      key: ValueKey('venue-${widget.venue.id}'),
      child: Column(
        children: [
          BookingTopBar(
            title: 'Chi tiết sân',
            onBack: widget.onBack,
            trailing: BookingCartIcon(count: widget.cart.length, onTap: widget.onGoCart),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 92),
              children: [
                BookingVenuePoster(venue: widget.venue),
                const SizedBox(height: 16),
                Text(
                  widget.venue.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                BookingInfoLine(icon: Icons.place_outlined, text: widget.venue.address),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${widget.venue.rating} (${widget.venue.reviewCount} đánh giá)'),
                    const Spacer(),
                    const Icon(Icons.schedule, color: bookingPrimary, size: 18),
                    Text(' ${widget.venue.openHours}'),
                  ],
                ),
                const SizedBox(height: 18),
                const BookingSectionTitle(title: 'Tiện ích'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.venue.amenities.map((item) => BookingSoftChip(label: item)).toList(),
                ),
                const SizedBox(height: 18),
                const BookingSectionTitle(title: 'Chọn sân'),
                ...widget.venue.fields.map(
                  (field) => _FieldTile(
                    field: field,
                    selected: field.id == widget.selectedField.id,
                    onTap: () => widget.onFieldChanged(field),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const BookingSectionTitle(title: 'Khung giờ'),
                    const Spacer(),
                    Text('$available slot trống', style: const TextStyle(color: bookingPrimary, fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _DateChip(label: 'Hôm nay', date: '2026-06-04', value: _date, onTap: _setDate)),
                    const SizedBox(width: 8),
                    Expanded(child: _DateChip(label: 'Ngày mai', date: '2026-06-05', value: _date, onTap: _setDate)),
                    const SizedBox(width: 8),
                    Expanded(child: _DateChip(label: 'Thứ 7', date: '2026-06-06', value: _date, onTap: _setDate)),
                  ],
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookingSlots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (context, index) {
                    final slot = bookingSlots[index];
                    final id = '${widget.selectedField.id}-$_date-${slot.id}';
                    final selected = widget.cart.any((item) => item.id == id);
                    return _SlotButton(
                      slot: slot,
                      selected: selected,
                      onTap: () => widget.onToggleSlot(slot, _date),
                    );
                  },
                ),
              ],
            ),
          ),
          BookingBottomAction(
            label: widget.cart.isEmpty ? 'Chọn slot để đặt sân' : 'Xem giỏ (${widget.cart.length})',
            icon: Icons.shopping_cart_outlined,
            enabled: widget.cart.isNotEmpty,
            onPressed: widget.onGoCart,
          ),
        ],
      ),
    );
  }

  void _setDate(String date) => setState(() => _date = date);
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.field, required this.selected, required this.onTap});

  final FieldInfo field;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BookingCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      borderColor: selected ? bookingPrimary : bookingLine,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: selected ? bookingPrimary : bookingMint,
            foregroundColor: selected ? Colors.white : bookingPrimary,
            child: Text(field.type),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(field.name, style: const TextStyle(fontWeight: FontWeight.w800))),
          Text(money(field.price), style: const TextStyle(color: bookingPrimary, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.date, required this.value, required this.onTap});

  final String label;
  final String date;
  final String value;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = date == value;
    return InkWell(
      onTap: () => onTap(date),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? bookingPrimary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? bookingPrimary : bookingLine),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: selected ? Colors.white : bookingText, fontWeight: FontWeight.w800, fontSize: 12)),
            Text(date.substring(5).replaceAll('-', '/'), style: TextStyle(color: selected ? Colors.white70 : bookingMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({required this.slot, required this.selected, required this.onTap});

  final SlotInfo slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = slot.status != SlotStatus.available;
    final color = selected ? bookingPrimary : disabled ? const Color(0xFFE6ECE8) : Colors.white;
    final textColor = selected ? Colors.white : disabled ? Colors.grey : bookingText;
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
        child: Text(slot.time.split(' - ').first, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
