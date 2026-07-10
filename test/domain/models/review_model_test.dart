import 'package:exe101/domain/models/review_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewModel booking hydration', () {
    test('creates a full review model from booking review dto', () {
      final createdAt = DateTime(2026, 7, 10, 9);
      final dto = BookingReviewDto(
        reviewId: 'review-1',
        rating: 5,
        comment: 'Good field',
        createdAt: createdAt,
      );

      final review = ReviewModel.fromBookingReview(
        dto,
        bookingId: 'booking-1',
        userId: 'customer-1',
        userName: 'Customer User',
        venueId: 'venue-1',
        venueName: 'Hoang Chien',
      );

      expect(review.reviewId, 'review-1');
      expect(review.bookingId, 'booking-1');
      expect(review.userId, 'customer-1');
      expect(review.userName, 'Customer User');
      expect(review.venueId, 'venue-1');
      expect(review.venueName, 'Hoang Chien');
      expect(review.rating, 5);
      expect(review.comment, 'Good field');
      expect(review.createdAt, createdAt);
    });

    test('provides a readable fallback when comment is empty', () {
      final review = ReviewModel(
        reviewId: 'review-1',
        userId: 'customer-1',
        venueId: 'venue-1',
        bookingId: 'booking-1',
        rating: 4,
        comment: '   ',
      );

      expect(review.displayComment, 'Khong co noi dung danh gia.');
    });
  });
}
