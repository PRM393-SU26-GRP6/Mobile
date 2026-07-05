import 'package:dio/dio.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/view/orders/payment_flow_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentFlowResolver', () {
    test('detects existing deposit payment error from Dio response message',
        () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/v1/payments/deposit'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/payments/deposit'),
          statusCode: 400,
          data: {
            'message':
                'Deposit payment is already in progress or has been paid.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      expect(PaymentFlowResolver.isExistingDepositPaymentError(error), isTrue);
    });

    test('detects existing final payment error from Dio response message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/v1/payments/final'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/payments/final'),
          statusCode: 400,
          data: {
            'message': 'Final payment is already in progress or has been paid.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
          PaymentFlowResolver.isExistingPaymentError(error, 'final'), isTrue);
    });

    test('selects reusable pending SePay deposit payment', () {
      final payments = [
        _payment(
          id: 'final-payment',
          type: 'Final',
          status: 'Pending',
          method: PaymentMethod.sePay,
        ),
        _payment(
          id: 'deposit-payment',
          type: 'Deposit',
          status: 'Processing',
          method: PaymentMethod.sePay,
        ),
        _payment(
          id: 'failed-deposit',
          type: 'Deposit',
          status: 'Failed',
          method: PaymentMethod.sePay,
        ),
      ];

      final payment = PaymentFlowResolver.findReusableDepositPayment(payments);

      expect(payment?.id, 'deposit-payment');
    });

    test('selects reusable pending SePay final payment', () {
      final payments = [
        _payment(
          id: 'deposit-payment',
          type: 'Deposit',
          status: 'Processing',
          method: PaymentMethod.sePay,
        ),
        _payment(
          id: 'final-payment',
          type: 'Final',
          status: 'Pending',
          method: PaymentMethod.sePay,
        ),
      ];

      final payment = PaymentFlowResolver.findReusablePayment(
        payments,
        paymentType: 'final',
      );

      expect(payment?.id, 'final-payment');
    });

    test('selects reusable pending SePay full upfront payment as final payment',
        () {
      final payments = [
        _payment(
          id: 'full-payment',
          type: 'Final',
          status: 'Pending',
          method: PaymentMethod.sePay,
        ),
      ];

      final payment = PaymentFlowResolver.findReusablePayment(
        payments,
        paymentType: 'full',
      );

      expect(payment?.id, 'full-payment');
    });

    test('does not reuse completed deposit payment', () {
      final payments = [
        _payment(
          id: 'completed-deposit',
          type: 'Deposit',
          status: 'Completed',
          method: PaymentMethod.sePay,
        ),
      ];

      final payment = PaymentFlowResolver.findReusableDepositPayment(payments);

      expect(payment, isNull);
    });
  });
}

PaymentModel _payment({
  required String id,
  required String type,
  required String status,
  required PaymentMethod method,
}) {
  return PaymentModel(
    id: id,
    bookingId: 'booking-1',
    amount: 75000,
    paymentStatus: status,
    paymentType: type,
    paymentMethod: method,
    gateway: 'SePay',
    createdAt: DateTime(2026, 7, 5),
  );
}
