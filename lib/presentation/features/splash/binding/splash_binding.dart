import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/presentation/features/splash/controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    Get.put<SplashController>(SplashController(apiService: apiService));
  }
}
