import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final ApiService apiService;

  SplashController({required this.apiService});

  bool _isNavigating = false;

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // small delay so splash UI is visible briefly
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      if (apiService is ApiServiceImpl) {
        final accessToken =
            await (apiService as ApiServiceImpl).getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          final role = await (apiService as ApiServiceImpl).getUserRole();
          if (role == 'Owner') {
            _navigateTo(AppPages.ownerHome);
            return;
          } else {
            _navigateTo(AppPages.customerHome);
            return;
          }
        }
      }
    } catch (_) {}

    // No token or error -> navigate to login
    _navigateTo(AppPages.login);
  }

  void navigateToLogin() {
    if (_isNavigating) return;
    _isNavigating = true;
    Get.offAllNamed(AppPages.login);
  }

  void _navigateTo(String route) {
    if (_isNavigating) return;
    _isNavigating = true;
    Get.offAllNamed(route);
  }
}
