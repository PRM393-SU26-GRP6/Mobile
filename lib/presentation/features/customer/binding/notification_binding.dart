import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/customer/controller/notification_controller.dart';
import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<UserRepository>()) {
      final apiService = Get.find<ApiServiceImpl>();
      Get.put<UserRepository>(UserRepository(apiService: apiService));
    }

    Get.lazyPut<NotificationController>(
      () => NotificationController(userRepository: Get.find<UserRepository>()),
    );
  }
}