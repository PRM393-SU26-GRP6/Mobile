part of '../api_service.dart';

extension UserEngagementApiFacade on ApiServiceImpl {
  Future<UserAuthData?> getUserProfile() => userService.getUserProfile();

  Future<bool> updateUserProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) =>
      userService.updateUserProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );

  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) =>
      notificationService.getNotifications(
        unreadOnly: unreadOnly,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  Future<int> getUnreadNotificationCount() =>
      notificationService.getUnreadNotificationCount();

  Future<bool> markNotificationAsRead(String notificationId) =>
      notificationService.markNotificationAsRead(notificationId);

  Future<bool> markAllNotificationsAsRead() =>
      notificationService.markAllNotificationsAsRead();

  Future<ValidateDiscountResponseDto?> validateDiscount(
    ValidateDiscountRequestDto request,
  ) =>
      discountService.validateDiscount(request);

  Future<List<DiscountDto>> getOwnerDiscounts() =>
      discountService.getOwnerDiscounts();

  Future<bool> createDiscount(DiscountDto discount) =>
      discountService.createDiscount(discount);

  Future<bool> updateDiscount(String id, DiscountDto discount) =>
      discountService.updateDiscount(id, discount);

  Future<bool> toggleDiscountStatus(String id) =>
      discountService.toggleDiscountStatus(id);

  Future<bool> deleteDiscount(String id) => discountService.deleteDiscount(id);

  Future<ReviewListResponse> getReviewsByVenue({
    required String venueId,
    int page = 1,
    int pageSize = 5,
  }) =>
      reviewService.getReviewsByVenue(
        venueId: venueId,
        page: page,
        pageSize: pageSize,
      );

  Future<List<ReviewModel>> getMyReviews() => reviewService.getMyReviews();

  Future<ReviewModel> createReview({
    required String venueId,
    required String bookingId,
    required int rating,
    required String comment,
  }) =>
      reviewService.createReview(
        venueId: venueId,
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );

  Future<ReviewModel> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) =>
      reviewService.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );

  Future<void> deleteReview(String reviewId) =>
      reviewService.deleteReview(reviewId);
}
