import 'package:dio/dio.dart';
import 'package:exe101/domain/models/login_response_model.dart';

class AuthFlowResolver {
  static const _verifyEmailMarker = 'please verify your email address';
  static const _otpSentMarker = 'otp code sent during registration';

  static String? extractMessage(dynamic source) {
    if (source == null) return null;

    if (source is LoginResponseModel) {
      return source.message;
    }

    if (source is DioException) {
      final data = source.response?.data;
      if (data is Map) {
        final message = data['message'] ?? data['error'];
        return message?.toString();
      }
    }

    return source.toString();
  }

  static bool shouldOpenOtpAfterRegister(dynamic source) {
    if (source is DioException) {
      return source.type == DioExceptionType.receiveTimeout;
    }

    return false;
  }

  static bool shouldOpenOtpAfterLogin(dynamic source) {
    final normalizedMessage = _normalize(extractMessage(source));
    if (normalizedMessage == null) return false;

    return _requiresEmailVerification(normalizedMessage);
  }

  static bool _requiresEmailVerification(String normalizedMessage) {
    return normalizedMessage.contains(_verifyEmailMarker) &&
        normalizedMessage.contains(_otpSentMarker);
  }

  static String? _normalize(String? message) {
    final trimmed = message?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.toLowerCase();
  }
}
