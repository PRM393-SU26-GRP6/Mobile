import 'package:exe101/domain/models/booking_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingDto payment summary', () {
    test('does not mark deposit as paid just because deposit amount exists',
        () {
      final booking = _booking(
        depositAmount: 150000,
        bookingStatus: 'Accepted',
      );

      expect(booking.hasSuccessfulDepositPayment, isFalse);
      expect(booking.paidDepositAmount, 0);
      expect(booking.depositRequirementLabel, 'Cọc cần thu');
    });

    test('marks deposit as paid only when deposit payment is successful', () {
      final booking = _booking(
        depositAmount: 150000,
        bookingStatus: 'Deposited',
        payments: [
          PaymentDto(
            amount: 150000,
            paymentStatus: 'Success',
            paymentType: 'Deposit',
          ),
        ],
      );

      expect(booking.hasSuccessfulDepositPayment, isTrue);
      expect(booking.paidDepositAmount, 150000);
      expect(booking.depositRequirementLabel, 'Đã đặt cọc');
    });

    test('allows deposit payment only after booking is accepted', () {
      final booking = _booking(
        depositAmount: 150000,
        bookingStatus: 'Accepted',
      );

      expect(booking.canPayDeposit, isTrue);
      expect(booking.canPayRemaining, isFalse);
    });

    test('allows remaining payment after deposit is confirmed', () {
      final booking = _booking(
        depositAmount: 150000,
        bookingStatus: 'Deposited',
        payments: [
          PaymentDto(
            amount: 150000,
            paymentStatus: 'Success',
            paymentType: 'Deposit',
          ),
        ],
      );

      expect(booking.canPayDeposit, isFalse);
      expect(booking.canPayRemaining, isTrue);
    });
  });
}

BookingDto _booking({
  required double depositAmount,
  required String bookingStatus,
  List<PaymentDto>? payments,
}) {
  return BookingDto(
    id: 'booking-1',
    userId: 'customer-1',
    fieldId: 'field-1',
    startTime: DateTime(2026, 7, 5, 9),
    endTime: DateTime(2026, 7, 5, 12),
    totalPrice: 300000,
    depositAmount: depositAmount,
    discountAmount: 0,
    bookingStatus: bookingStatus,
    createdAt: DateTime(2026, 7, 5),
    payments: payments,
  );
}
