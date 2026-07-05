import 'package:dio/dio.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/repositories/user_repository.dart';
import 'package:exe101/presentation/features/auth/controller/auth_flow_resolver.dart';
import 'package:exe101/presentation/features/auth/controller/otp_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFlowResolver', () {
    test('does not open OTP after register when email already exists', () {
      final response = LoginResponseModel(
        success: false,
        message: 'User with this email already exists',
      );

      expect(AuthFlowResolver.shouldOpenOtpAfterRegister(response), isFalse);
    });

    test('opens OTP after register receive timeout', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/register/customer'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(AuthFlowResolver.shouldOpenOtpAfterRegister(error), isTrue);
    });

    test('opens OTP after login when email is not verified', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/login'),
          statusCode: 401,
          data: {
            'success': false,
            'message':
                'Please verify your email address using the OTP code sent during registration.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      expect(AuthFlowResolver.shouldOpenOtpAfterLogin(error), isTrue);
    });

    test('does not open OTP for unrelated auth errors', () {
      final response = LoginResponseModel(
        success: false,
        message: 'Email or password is incorrect',
      );

      expect(AuthFlowResolver.shouldOpenOtpAfterLogin(response), isFalse);
      expect(AuthFlowResolver.shouldOpenOtpAfterRegister(response), isFalse);
    });

    test('uses six digits for OTP input', () {
      expect(OtpController.otpLength, 6);
    });

    test('applies latest route email before verifying OTP', () {
      final controller = OtpController(
        userRepository: UserRepository(apiService: ApiServiceImpl(Dio())),
      );

      controller.applyRouteArguments({
        'email': 'old-user@example.com',
        'isRegister': true,
      });
      controller.applyRouteArguments({
        'email': ' baophi852@gmail.com ',
        'isRegister': false,
      });

      expect(controller.email, 'baophi852@gmail.com');
      expect(controller.isRegister, isFalse);
    });
  });
}
