import 'package:flutter/material.dart';

import '../../../domain/booking_models.dart';
import '../booking_ui.dart';
import 'date_chip.dart';
import 'date_option.dart';
import 'field_tile.dart';
import 'review_tile.dart';
import 'slot_grid.dart';

class VenueDetailContent extends StatelessWidget {
  const VenueDetailContent({
    required this.venue,
    required this.originalVenue,
    required this.activeField,
    required this.slots,
    required this.cart,
    required this.date,
    required this.dateOptions,
    required this.loadingDetail,
    required this.loadingSlots,
    required this.showFallbackNotice,
    required this.onSelectField,
    required this.onDateChanged,
    required this.onToggleSlot,
    super.key,
  });

  final Venue venue;
  final Venue originalVenue;
  final FieldInfo activeField;
  final List<SlotInfo> slots;
  final List<CartItem> cart;
  final String date;
  final List<DateOption> dateOptions;
  final bool loadingDetail;
  final bool loadingSlots;
  final bool showFallbackNotice;
  final ValueChanged<FieldInfo> onSelectField;
  final ValueChanged<String> onDateChanged;
  final void Function(SlotInfo slot, String date) onToggleSlot;

  @override
  Widget build(BuildContext context) {
    final available = slots
        .where((slot) => slot.status == SlotStatus.available)
        .length;
    final amenities = venue.amenities.isEmpty
        ? originalVenue.amenities
        : venue.amenities;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 92),
      children: [
        if (loadingDetail) const LinearProgressIndicator(),
        if (showFallbackNotice) ...[
          const BookingNotice(
            text: 'Đang dùng dữ liệu mẫu vì chưa kết nối được API chi tiết.',
          ),
          const SizedBox(height: 12),
        ],
        BookingVenuePoster(venue: venue),
        const SizedBox(height: 16),
        Text(
          venue.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        BookingInfoLine(icon: Icons.place_outlined, text: venue.address),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(' ${venue.rating} (${venue.reviewCount} đánh giá)'),
            const Spacer(),
            const Icon(Icons.schedule, color: bookingPrimary, size: 18),
            Text(' ${venue.openHours}'),
          ],
        ),
        const SizedBox(height: 18),
        const BookingSectionTitle(title: 'Tiện ích'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities
              .map((item) => BookingSoftChip(label: item))
              .toList(),
        ),
        const SizedBox(height: 18),
        const BookingSectionTitle(title: 'Chọn sân'),
        ...venue.fields.map(
          (field) => FieldTile(
            field: field,
            selected: field.id == activeField.id,
            onTap: () => onSelectField(field),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const BookingSectionTitle(title: 'Khung giờ'),
            const Spacer(),
            if (loadingSlots)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '$available slot trống',
                style: const TextStyle(
                  color: bookingPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        Row(
          children: dateOptions.map((option) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: VenueDateChip(
                  label: option.label,
                  date: option.date,
                  value: date,
                  onTap: onDateChanged,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        SlotGrid(
          slots: slots,
          cart: cart,
          activeField: activeField,
          date: date,
          onToggleSlot: onToggleSlot,
        ),
        const SizedBox(height: 18),
        if (venue.reviews.isNotEmpty) ...[
          const BookingSectionTitle(title: 'Đánh giá gần đây'),
          ...venue.reviews.take(3).map((review) {
            return ReviewTile(review: review);
          }),
        ],
      ],
    );
  }
}
