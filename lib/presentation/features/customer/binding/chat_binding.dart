import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/repositories/chat_repository.dart';
import 'package:exe101/presentation/features/customer/controller/chat_actions_controller.dart';
import 'package:get/get.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final apiService = Get.find<ApiServiceImpl>();
    if (!Get.isRegistered<ChatRepository>()) {
      Get.lazyPut<ChatRepository>(
        () => ChatRepository(
          authApiService: apiService.authService,
          chatApiService: apiService.chatService,
          venueApiService: apiService.venueService,
        ),
        fenix: true,
      );
    }
    Get.lazyPut<ChatActionsController>(
      () => ChatActionsController(
        chatRepository: Get.find(),
        signalRService: Get.find(),
      ),
      fenix: true,
    );
  }
}
