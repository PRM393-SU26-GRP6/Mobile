part of 'venue_detail_controller.dart';

extension VenueDetailReviewActions on VenueDetailController {
  Future<void> loadReviews(String venueId) async {
    if (isLoadingReviews.value) return;
    try {
      isLoadingReviews.value = true;
      reviewsError.value = '';
      reviewPage.value = 1;
      final response = await (apiService as ApiServiceImpl).getReviewsByVenue(
        venueId: venueId,
        page: reviewPage.value,
        pageSize: VenueDetailController.reviewsPageSize,
      );
      reviews.assignAll(response.reviews);
      reviewTotalCount.value = response.totalCount;
      reviewAverageRating.value = response.averageRating;
      hasMoreReviews.value = response.hasMore;
      _reviewsLoaded = true;
    } catch (_) {
      reviewsError.value = 'Không thể tải đánh giá';
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> loadMoreReviews() async {
    final currentVenue = venue.value;
    if (currentVenue == null ||
        isLoadingMoreReviews.value ||
        !hasMoreReviews.value) {
      return;
    }
    try {
      isLoadingMoreReviews.value = true;
      final nextPage = reviewPage.value + 1;
      final response = await (apiService as ApiServiceImpl).getReviewsByVenue(
        venueId: currentVenue.id,
        page: nextPage,
        pageSize: VenueDetailController.reviewsPageSize,
      );
      reviews.addAll(response.reviews);
      reviewPage.value = nextPage;
      reviewTotalCount.value = response.totalCount;
      reviewAverageRating.value = response.averageRating;
      hasMoreReviews.value = response.hasMore;
    } catch (_) {
      reviewsError.value = 'Không thể tải thêm đánh giá';
    } finally {
      isLoadingMoreReviews.value = false;
    }
  }

  bool get hasReviewsLoaded => _reviewsLoaded;

  Future<FieldRatingDto?> loadFieldAverageRating(String fieldId) async {
    if (fieldRatings.containsKey(fieldId)) return fieldRatings[fieldId];
    if (isLoadingFieldRating[fieldId] == true) return null;

    isLoadingFieldRating[fieldId] = true;
    fieldRatingError.remove(fieldId);
    try {
      final rating = await reviewRepository.getFieldAverageRating(fieldId);
      fieldRatings[fieldId] = rating;
      return rating;
    } catch (_) {
      fieldRatingError[fieldId] = 'Không thể tải đánh giá sân';
      return null;
    } finally {
      isLoadingFieldRating[fieldId] = false;
    }
  }

  FieldRatingDto? ratingFor(String fieldId) => fieldRatings[fieldId];
}
