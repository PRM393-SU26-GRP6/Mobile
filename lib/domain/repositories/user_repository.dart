import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/login_response_model.dart';

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
}
