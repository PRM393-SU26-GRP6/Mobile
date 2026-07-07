import 'package:exe101/data/remote/review_api_service.dart';
import 'package:exe101/domain/models/review_model.dart';

/// Wraps focused review lookup calls so controllers depend on a stable
/// domain interface instead of the remote service directly.
class ReviewRepository {
  final ReviewApiService reviewApiService;

  ReviewRepository({required this.reviewApiService});

  /// Returns the review attached to [bookingId], or null if the booking
  /// has no review yet.
  Future<BookingReviewDto?> getBookingReview(String bookingId) {
    return reviewApiService.getBookingReview(bookingId);
  }

  /// Returns aggregate rating info for [fieldId].
  Future<FieldRatingDto> getFieldAverageRating(String fieldId) {
    return reviewApiService.getFieldAverageRating(fieldId);
  }
}
