import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/payment_repository.dart';
import 'package:exe101/presentation/features/customer/controller/payment_actions_controller.dart';
import 'package:get/get.dart';

class PaymentBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    if (!Get.isRegistered<PaymentRepository>()) {
      Get.lazyPut<PaymentRepository>(
        () => PaymentRepository(paymentApiService: apiService.paymentService),
        fenix: true,
      );
    }
    Get.lazyPut<PaymentActionsController>(
      () => PaymentActionsController(paymentRepository: Get.find()),
      fenix: true,
    );
  }
}
