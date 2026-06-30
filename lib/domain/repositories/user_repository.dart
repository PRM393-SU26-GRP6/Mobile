import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/models/notification_model.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository({required this.apiService});

  Future<LoginResponseModel> login(String email, String password) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).login(email, password);
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<LoginResponseModel> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).registerCustomer(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<LoginResponseModel> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).registerOwner(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<LoginResponseModel> verifyOtp(String email, String otp) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).verifyOtp(email, otp);
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<UserAuthData?> getUserProfile() async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).getUserProfile();
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).updateUserProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).getNotifications(
        unreadOnly: unreadOnly,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<int> getUnreadNotificationCount() async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).getUnreadNotificationCount();
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).markNotificationAsRead(notificationId);
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }

  Future<bool> markAllNotificationsAsRead() async {
    if (apiService is ApiServiceImpl) {
      return (apiService as ApiServiceImpl).markAllNotificationsAsRead();
    }
    throw Exception('ApiService must be ApiServiceImpl');
  }
}
