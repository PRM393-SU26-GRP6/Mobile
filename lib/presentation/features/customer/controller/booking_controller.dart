import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final ApiService apiService;

  final bookings = <BookingDto>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;
  final statusFilter = ''.obs;

  // Reviews của user hiện tại — map theo bookingId (mỗi booking tối đa 1 review).
  // Dùng RxMap để reactive với Obx.
  final myReviews = RxMap<String, ReviewModel>();
  final isLoadingReviews = false.obs;
  final reviewsError = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _status;
  String? _from;
  String? _to;

  BookingController({required this.apiService});

  List<BookingDto> get filteredBookings {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return bookings;

    return bookings.where((booking) {
      final text = [
        booking.id,
        booking.bookingStatus ?? '',
        booking.statusLabel,
        for (final item in booking.items ?? const <BookingItemDto>[]) ...[
          item.venueName ?? '',
          item.fieldName ?? '',
        ],
      ].join(' ').toLowerCase();
      return text.contains(query);
    }).toList();
  }

  Future<void> loadBookings({
    bool refresh = false,
    String? status,
    bool clearStatus = false,
    String? from,
    String? to,
  }) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      bookings.clear();
    }

    // update filters only when provided (null means keep existing)
    if (clearStatus) {
      _status = null;
    } else if (status != null) {
      _status = status.isEmpty ? null : status;
    }
    if (from != null) _from = from;
    if (to != null) _to = to;

    if (!hasMore.value) return;

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final result = await (apiService as ApiServiceImpl).getBookingHistory(
        status: _status,
        from: _from,
        to: _to,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (result.length < _pageSize) {
        hasMore.value = false;
      }

      bookings.addAll(result);
      _currentPage++;
    } catch (e) {
      error.value = 'Không thể tải lịch sử đặt sân';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshBookings() => loadBookings(refresh: true);

  Future<void> applyStatusFilter(String status) {
    statusFilter.value = status;
    return loadBookings(
      refresh: true,
      status: status,
      clearStatus: status.isEmpty,
    );
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  /// Load danh sách review của user hiện tại để map với bookingId
  Future<void> loadMyReviews() async {
    if (isLoadingReviews.value) return;
    try {
      isLoadingReviews.value = true;
      reviewsError.value = '';
      final list = await (apiService as ApiServiceImpl).getMyReviews();
      myReviews.clear();
      for (final r in list) {
        final bid = r.bookingId;
        if (bid != null && bid.isNotEmpty) {
          myReviews[bid] = r;
        }
      }
    } catch (e) {
      reviewsError.value = 'Không thể tải đánh giá của bạn';
    } finally {
      isLoadingReviews.value = false;
    }
  }

  ReviewModel? reviewForBooking(String bookingId) => myReviews[bookingId];

  bool hasReviewFor(String bookingId) => myReviews.containsKey(bookingId);

  /// Cập nhật cache local sau khi user tạo/sửa review (không cần gọi lại API list)
  void upsertReview(ReviewModel review) {
    final bid = review.bookingId;
    if (bid != null && bid.isNotEmpty) {
      myReviews[bid] = review;
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
    if (result.bookingId != null && result.bookingId!.isNotEmpty) {
      myReviews[result.bookingId!] = result;
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
    if (result.bookingId != null && result.bookingId!.isNotEmpty) {
      myReviews[result.bookingId!] = result;
    }
    return result;
  }

  Future<BookingDto?> createBooking({
    required List<String> slotIds,
    required String discountCode,
    required String note,
  }) async {
    try {
      final result = await (apiService as ApiServiceImpl).createBooking(
        slotIds: slotIds,
        discountCode: discountCode,
        note: note,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
