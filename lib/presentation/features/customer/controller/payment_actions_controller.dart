import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/domain/repositories/payment_repository.dart';
import 'package:get/get.dart';

class PaymentActionsController extends GetxController {
  final PaymentRepository paymentRepository;

  PaymentActionsController({required this.paymentRepository});

  Future<List<PaymentModel>> getByBooking(String bookingId) {
    return paymentRepository.getByBooking(bookingId);
  }

  Future<PaymentModel> createDeposit(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) {
    return paymentRepository.createDeposit(
      bookingId,
      paymentMethod: paymentMethod,
    );
  }

  Future<PaymentModel> createFinal(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) {
    return paymentRepository.createFinal(
      bookingId,
      paymentMethod: paymentMethod,
    );
  }

  Future<PaymentModel?> getById(String paymentId) {
    return paymentRepository.getById(paymentId);
  }

  Future<SePayQRInfoModel?> getQrInfo(String paymentId) {
    return paymentRepository.getQrInfo(paymentId);
  }
}
