import 'package:dio/dio.dart';

class ApiErrorHandler {
  const ApiErrorHandler._();

  static String getMessage(Object error) {
    if (error is! DioException) return error.toString();

    final responseData = error.response?.data;
    if (responseData is Map) {
      final message = responseData['message'] ?? responseData['error'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Kết nối quá thời gian. Vui lòng kiểm tra mạng.';
      case DioExceptionType.sendTimeout:
        return 'Không thể gửi yêu cầu. Vui lòng thử lại.';
      case DioExceptionType.receiveTimeout:
        return 'Máy chủ phản hồi chậm. Vui lòng thử lại.';
      case DioExceptionType.badResponse:
        return _messageForStatusCode(error.response?.statusCode ?? 0);
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy.';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
      case DioExceptionType.badCertificate:
        return 'Không thể xác minh kết nối bảo mật.';
      case DioExceptionType.unknown:
        return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  static String _messageForStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Thông tin đăng nhập không hợp lệ.';
      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';
      case 404:
        return 'Không tìm thấy dữ liệu.';
      case 500:
        return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
      default:
        return 'Yêu cầu thất bại (mã $statusCode).';
    }
  }
}
