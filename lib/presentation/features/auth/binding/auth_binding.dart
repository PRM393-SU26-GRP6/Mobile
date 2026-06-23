import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/controller/otp_controller.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:get/get.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    final userRepository = UserRepository(apiService: apiService);
    Get.put<UserRepository>(userRepository);
    Get.put<AuthController>(AuthController(userRepository: userRepository));
    Get.put<RegisterController>(RegisterController(userRepository: userRepository));
    Get.put<OtpController>(OtpController(userRepository: userRepository));
  }
}
