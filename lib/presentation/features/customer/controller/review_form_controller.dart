import 'package:dio/dio.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:flutter/material.dart';

enum ReviewFormMode { create, edit }

class ReviewFormController extends ChangeNotifier {
  ReviewFormController({
    required this.bookingController,
    required this.booking,
    required this.mode,
    this.existing,
  }) {
    rating = isEdit && existing != null ? existing!.rating.clamp(1, 5) : 0;
    commentController.text = existing?.comment ?? '';
  }

  final BookingController bookingController;
  final BookingDto booking;
  final ReviewFormMode mode;
  final ReviewModel? existing;
  final commentController = TextEditingController();

  late int rating;
  String? errorMessage;
  bool isSubmitting = false;

  bool get isEdit => mode == ReviewFormMode.edit;
  String get title => isEdit ? 'Chỉnh sửa đánh giá' : 'Đánh giá sân';
  String get submitLabel => isEdit ? 'Cập nhật' : 'Gửi đánh giá';
  String get successMessage =>
      isEdit ? 'Đã cập nhật đánh giá' : 'Cảm ơn bạn đã đánh giá sân';

  String get venueName {
    final items = booking.items;
    return items != null && items.isNotEmpty
        ? items.first.venueName ?? 'Sân'
        : 'Sân';
  }

  void selectRating(int value) {
    rating = rating == value ? 0 : value;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    if (rating == 0) {
      errorMessage = 'Vui lòng chọn số sao.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();
    try {
      if (isEdit && existing != null) {
        await bookingController.updateReview(
          reviewId: existing!.reviewId,
          rating: rating,
          comment: commentController.text.trim(),
        );
      } else {
        await bookingController.createReview(
          venueId: _venueId,
          bookingId: booking.id,
          rating: rating,
          comment: commentController.text.trim(),
        );
      }
      return true;
    } catch (error) {
      errorMessage = _friendlyMessage(error);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  String get _venueId {
    final items = booking.items;
    return items != null && items.isNotEmpty
        ? items.first.venueId
        : booking.fieldId;
  }

  String _friendlyMessage(Object error) {
    if (error is! DioException) {
      return 'Không thể gửi đánh giá. Vui lòng thử lại.';
    }
    final data = error.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (error.response?.statusCode) {
      case 400:
        return isEdit
            ? 'Dữ liệu cập nhật không hợp lệ.'
            : 'Booking này đã được đánh giá hoặc dữ liệu không hợp lệ.';
      case 401:
        return 'Phiên đăng nhập đã hết hạn.';
      case 404:
        return 'Không tìm thấy đánh giá hoặc booking.';
      default:
        return 'Không thể gửi đánh giá. Vui lòng thử lại.';
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
