import 'auth_models.dart';

class AuthApiClient {
  Future<AuthResponse> login(LoginRequest request) {
    throw const AuthApiException(
      'HTTP client is not available on this platform.',
    );
  }

  Future<AuthResponse> register(RegisterRequest request) {
    throw const AuthApiException(
      'HTTP client is not available on this platform.',
    );
  }

  Future<AuthResponse> refreshToken({
    required String accessToken,
    required String refreshToken,
  }) {
    throw const AuthApiException(
      'HTTP client is not available on this platform.',
    );
  }

  Future<AuthResponse> logout({required String accessToken}) {
    throw const AuthApiException(
      'HTTP client is not available on this platform.',
    );
  }

  void dispose() {}
}
