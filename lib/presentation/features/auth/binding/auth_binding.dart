import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:exe101/presentation/features/auth/controller/otp_controller.dart';
import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(
        () => UserRepository(apiService: apiService),
        fenix: true,
      );
    }

    Get.lazyPut<AuthController>(
      () => AuthController(userRepository: Get.find()),
      fenix: true,
    );
    Get.lazyPut<RegisterController>(
      () => RegisterController(userRepository: Get.find()),
    );
    Get.lazyPut<OtpController>(
      () => OtpController(userRepository: Get.find()),
    );
    Get.lazyPut<UserProfileController>(
      () => UserProfileController(userRepository: Get.find()),
    );
  }
}
