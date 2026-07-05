import 'package:dio/dio.dart';
import 'package:exe101/domain/models/payment_model.dart';

class PaymentFlowResolver {
  static bool isExistingDepositPaymentError(dynamic error) {
    return isExistingPaymentError(error, 'deposit');
  }

  static bool isExistingPaymentError(dynamic error, String paymentType) {
    final message = _extractMessage(error)?.toLowerCase() ?? '';
    final type = paymentType.toLowerCase();
    final isFullUpfront = type == 'full';
    final isMatchingPayment = message.contains('$type payment') ||
        (isFullUpfront && message.contains('payment')) ||
        (type == 'final' && message.contains('remaining amount'));

    return isMatchingPayment &&
        (message.contains('already in progress') ||
            message.contains('has been paid'));
  }

  static PaymentModel? findReusableDepositPayment(List<PaymentModel> payments) {
    return findReusablePayment(payments, paymentType: 'deposit');
  }

  static PaymentModel? findReusablePayment(
    List<PaymentModel> payments, {
    required String paymentType,
  }) {
    final expectedType = paymentType.toLowerCase() == 'full'
        ? 'final'
        : paymentType.toLowerCase();
    for (final payment in payments) {
      final type = payment.paymentType.toLowerCase();
      if (!type.contains(expectedType)) continue;
      if (payment.paymentMethod != PaymentMethod.sePay) continue;
      if (!payment.isPending) continue;
      return payment;
    }
    return null;
  }

  static String? _extractMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        return (data['message'] ?? data['title'] ?? data['detail'])?.toString();
      }
      return error.message;
    }
    return error?.toString();
  }
}
