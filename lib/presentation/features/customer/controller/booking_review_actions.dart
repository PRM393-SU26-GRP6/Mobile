part of 'booking_controller.dart';

extension BookingReviewControllerActions on BookingController {
  Future<void> loadMyReviews() async {
    if (isLoadingReviews.value) return;
    try {
      isLoadingReviews.value = true;
      reviewsError.value = '';
      final list = await (apiService as ApiServiceImpl).getMyReviews();
      myReviews.clear();
      for (final review in list) {
        final bookingId = review.bookingId;
        if (bookingId != null && bookingId.isNotEmpty) {
          myReviews[bookingId] = review;
        }
      }
    } catch (_) {
      reviewsError.value = 'Không thể tải đánh giá của bạn';
    } finally {
      isLoadingReviews.value = false;
    }
  }

  ReviewModel? reviewForBooking(String bookingId) => myReviews[bookingId];

  bool hasReviewFor(String bookingId) => myReviews.containsKey(bookingId);

  Future<BookingReviewDto?> loadBookingReview(String bookingId) async {
    try {
      final dto = await reviewRepository.getBookingReview(bookingId);
      if (dto != null) {
        myReviews[bookingId] = ReviewModel.fromBookingReview(
          dto,
          bookingId: bookingId,
        );
      }
      return dto;
    } catch (_) {
      reviewsError.value = 'Không thể tải đánh giá của lần đặt sân';
      return null;
    }
  }

  void upsertReview(ReviewModel review) {
    final bookingId = review.bookingId;
    if (bookingId != null && bookingId.isNotEmpty) {
      myReviews[bookingId] = review;
    }
  }

  void removeReviewForBooking(String bookingId) {
    myReviews.remove(bookingId);
  }

  Future<void> deleteReview(String reviewId) async {
    await (apiService as ApiServiceImpl).deleteReview(reviewId);
  }

  Future<ReviewModel> createReview({
    required String venueId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final result = await (apiService as ApiServiceImpl).createReview(
      venueId: venueId,
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
    final resultBookingId = result.bookingId;
    if (resultBookingId != null && resultBookingId.isNotEmpty) {
      myReviews[resultBookingId] = result;
    }
    return result;
  }

  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    final result = await (apiService as ApiServiceImpl).updateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );
    final bookingId = result.bookingId;
    if (bookingId != null && bookingId.isNotEmpty) {
      myReviews[bookingId] = result;
    }
    return result;
  }
}
