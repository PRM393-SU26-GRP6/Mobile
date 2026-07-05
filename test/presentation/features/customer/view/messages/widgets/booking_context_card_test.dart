import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/view/messages/widgets/booking_context_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders booking context details and view action',
      (tester) async {
    var didTapViewDetails = false;
    final booking = BookingDto(
      id: 'booking-1',
      userId: 'customer-1',
      fieldId: 'field-1',
      startTime: DateTime(2026, 7, 5, 7),
      endTime: DateTime(2026, 7, 5, 8),
      totalPrice: 150000,
      depositAmount: 75000,
      discountAmount: 0,
      bookingStatus: 'Accepted',
      note: 'Khách tới sớm 10 phút',
      createdAt: DateTime(2026, 7, 4),
      items: [
        BookingItemDto(
          bookingItemId: 'item-1',
          slotId: 'slot-1',
          fieldId: 'field-1',
          fieldName: 'Sân A',
          venueId: 'venue-1',
          venueName: 'PitchBook Arena',
          startTime: DateTime(2026, 7, 5, 7),
          endTime: DateTime(2026, 7, 5, 8),
          price: 150000,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingContextCard(
            booking: booking,
            onViewDetails: () => didTapViewDetails = true,
          ),
        ),
      ),
    );

    expect(find.text('Đã xác nhận'), findsOneWidget);
    expect(find.text('Sân A'), findsOneWidget);
    expect(find.text('07:00 - 08:00'), findsOneWidget);
    expect(find.text('150000K'), findsOneWidget);
    expect(find.text('Đặt cọc: 75000K'), findsOneWidget);
    expect(find.text('Khách tới sớm 10 phút'), findsOneWidget);

    await tester.tap(find.text('Xem đơn'));
    expect(didTapViewDetails, isTrue);
  });
}
