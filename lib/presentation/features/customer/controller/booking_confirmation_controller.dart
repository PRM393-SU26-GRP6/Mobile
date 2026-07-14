import 'package:dio/dio.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:flutter/material.dart';

enum BookingConfirmationStatus { idle, loading, success, error }

class BookingConfirmationController extends ChangeNotifier {
  BookingConfirmationController({
    required this.bookingController,
    required this.slotIds,
    required this.totalPrice,
  }) {
    bookingController.clearDiscount(totalPrice);
  }

  final BookingController bookingController;
  final List<String> slotIds;
  final double totalPrice;

  final discountTextController = TextEditingController();
  final noteTextController = TextEditingController();

  BookingConfirmationStatus status = BookingConfirmationStatus.idle;
  String errorMessage = '';

  bool get isLoading => status == BookingConfirmationStatus.loading;
  bool get isSuccess => status == BookingConfirmationStatus.success;

  Future<void> validateDiscount() async {
    final code = discountTextController.text.trim();
    if (code.isEmpty) {
      bookingController.clearDiscount(totalPrice);
      return;
    }

    _setLoading();
    await bookingController.validateDiscount(
      code: code,
      fieldId: null,
      slotIds: slotIds,
      totalAmount: totalPrice,
    );
    status = BookingConfirmationStatus.idle;
    notifyListeners();
  }

  Future<void> confirm() async {
    _setLoading();
    try {
      await bookingController.createBooking(
        slotIds: slotIds,
        discountCode: bookingController.isDiscountValid.value
            ? bookingController.discountCode.value
            : '',
        note: noteTextController.text.trim(),
      );
      status = BookingConfirmationStatus.success;
    } catch (error) {
      status = BookingConfirmationStatus.error;
      errorMessage = _bookingErrorMessage(error);
    }
    notifyListeners();
  }

  void _setLoading() {
    status = BookingConfirmationStatus.loading;
    errorMessage = '';
    notifyListeners();
  }

  String _bookingErrorMessage(Object error) {
    if (error is! DioException) return 'Đặt sân thất bại. Vui lòng thử lại.';

    final statusCode = error.response?.statusCode;
    final response = error.response?.data;
    final serverMessage =
        response is Map ? response['message']?.toString() : '';
    final normalizedMessage = serverMessage?.toLowerCase() ?? '';
    final isSlotConflict = normalizedMessage.contains('slot') &&
        (normalizedMessage.contains('not available') ||
            normalizedMessage.contains('already booked') ||
            normalizedMessage.contains('another user'));
    if (statusCode == 409 || isSlotConflict) {
      return 'Một hoặc nhiều khung giờ vừa được người khác chọn. '
          'Vui lòng đóng hộp thoại và chọn lại.';
    }
    switch (statusCode) {
      case 400:
        return serverMessage?.isNotEmpty == true
            ? serverMessage!
            : 'Dữ liệu đặt sân không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập đã hết hạn.';
      default:
        return serverMessage?.isNotEmpty == true
            ? serverMessage!
            : 'Không thể đặt sân. Vui lòng kiểm tra kết nối.';
    }
  }

  @override
  void dispose() {
    discountTextController.dispose();
    noteTextController.dispose();
    super.dispose();
  }
}
