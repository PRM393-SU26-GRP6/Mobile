import 'package:exe101/data/remote/payment/payment_api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';

class PaymentRepository {
  final PaymentApiService paymentApiService;

  PaymentRepository({required this.paymentApiService});

  Future<List<PaymentModel>> getByBooking(String bookingId) {
    return paymentApiService.getPaymentsByBooking(bookingId);
  }

  Future<PaymentModel> createDeposit(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) {
    return paymentApiService.createDepositPayment(
      bookingId,
      paymentMethod: paymentMethod,
    );
  }

  Future<PaymentModel> createFinal(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) {
    return paymentApiService.createFinalPayment(
      bookingId,
      paymentMethod: paymentMethod,
    );
  }

  Future<PaymentModel?> getById(String paymentId) {
    return paymentApiService.getPaymentById(paymentId);
  }

  Future<SePayQRInfoModel?> getQrInfo(String paymentId) {
    return paymentApiService.getSePayQRInfo(paymentId);
  }
}
