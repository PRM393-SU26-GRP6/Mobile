import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exe101/core/theme/app_theme.dart';

class VenueDetailController extends GetxController {
  final ApiService apiService;
  final SlotRepository slotRepository;
  final ReviewRepository reviewRepository;

  final venue = Rxn<VenueModel>();
  final fields = <FootballFieldDto>[].obs;
  final timeSlots = <TimeSlotDto>[].obs;

  final isLoadingVenue = false.obs;
  final isLoadingFields = false.obs;
  final isLoadingSlots = false.obs;

  final selectedField = Rxn<FootballFieldDto>();
  final selectedDate = Rxn<DateTime>();
  final selectedSlotIds = <String>[].obs;

  final error = ''.obs;

  // --- Reviews state ---
  static const int reviewsPageSize = 5;
  final reviews = <ReviewModel>[].obs;
  final isLoadingReviews = false.obs;
  final isLoadingMoreReviews = false.obs;
  final reviewPage = 1.obs;
  final reviewTotalCount = 0.obs;
  final reviewAverageRating = 0.0.obs;
  final hasMoreReviews = false.obs;
  final reviewsError = ''.obs;
  bool _reviewsLoaded = false;

  /// Current page index for the venue image carousel.
  final currentImageIndex = 0.obs;
  final PageController imagePageController = PageController();

  /// Per-field average rating cache (keyed by fieldId).
  /// Lazy-loaded so the venue detail page never blocks on rating fetches.
  final fieldRatings = <String, FieldRatingDto>{}.obs;
  final isLoadingFieldRating = <String, bool>{}.obs;
  final fieldRatingError = <String, String>{}.obs;

  /// Tracks whether a slot-unlock has already been attempted for the
  /// currently held selection — prevents duplicate unlock calls when
  /// `onClose` and a manual "clear selection" both fire.
  bool _unlockDispatched = false;

  VenueDetailController({
    required this.apiService,
    required this.slotRepository,
    required this.reviewRepository,
  });

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is VenueModel) {
      venue.value = arg;
      loadFields(arg.id);
      loadReviews(arg.id);
    } else if (arg is String && arg.isNotEmpty) {
      loadVenue(arg);
    }
  }

  Future<void> loadVenue(String venueId) async {
    try {
      isLoadingVenue.value = true;
      error.value = '';
      final result = await (apiService as ApiServiceImpl).getVenueById(venueId);
      venue.value = result;
      if (result != null) {
        loadFields(result.id);
        loadReviews(result.id);
      }
    } catch (e) {
      error.value = 'Không thể tải thông tin sân: $e';
    } finally {
      isLoadingVenue.value = false;
    }
  }

  /// Refreshes venue data (especially images) after owner uploads new photos.
  Future<void> refreshVenue() async {
    final current = venue.value;
    if (current == null) return;
    await loadVenue(current.id);
  }

  Future<void> loadFields(String venueId) async {
    try {
      isLoadingFields.value = true;
      final result =
          await (apiService as ApiServiceImpl).getFieldsByVenue(venueId);
      fields.value = result;
    } catch (e) {
      fields.clear();
    } finally {
      isLoadingFields.value = false;
    }
  }

  Future<void> loadSlots(String fieldId) async {
    try {
      isLoadingSlots.value = true;
      final result =
          await (apiService as ApiServiceImpl).getSlotsByField(fieldId);
      timeSlots.value = result;
      selectedSlotIds.clear();
      final dates = availableDates;
      if (dates.isNotEmpty) {
        selectedDate.value = dates.first;
      } else {
        selectedDate.value = null;
      }
    } catch (e) {
      error.value = 'Không thể tải khung giờ: $e';
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectField(FootballFieldDto field) {
    selectedField.value = field;
    selectedSlotIds.clear();
    selectedDate.value = null;
    timeSlots.clear();
    loadSlots(field.id);
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  Future<void> toggleSlot(String slotId) async {
    if (selectedSlotIds.contains(slotId)) {
      selectedSlotIds.remove(slotId);
      slotRepository.unlockSlot(slotId);
    } else {
      final slot = timeSlots.firstWhereOrNull((s) => s.slotId == slotId);
      if (slot == null || selectedField.value == null) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        barrierDismissible: false,
      );

      final success = await slotRepository.lockSlot(
        slotId: slot.slotId,
        fieldId: selectedField.value!.id,
        startTime: slot.startTime,
        endTime: slot.endTime,
        selectedDate: slot.selectedDate,
      );

      Get.back(); // close loading dialog

      if (success) {
        selectedSlotIds.add(slotId);
      } else {
        Get.snackbar(
          'Lỗi',
          'Khung giờ này đã có người đặt hoặc đang giữ chỗ.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  List<DateTime> get availableDates {
    final dates = <String, DateTime>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final slot in timeSlots) {
      if (slot.selectedDate.isEmpty) continue;
      final parts = slot.selectedDate.split('-');
      if (parts.length != 3) continue;
      try {
        final d = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        if (d.isBefore(today)) continue;
        dates[slot.selectedDate] = d;
      } catch (_) {
        continue;
      }
    }
    final list = dates.values.toList()..sort();
    return list;
  }

  List<TimeSlotDto> get slotsForSelectedDate {
    if (selectedDate.value == null) return [];
    final ymd =
        '${selectedDate.value!.year.toString().padLeft(4, '0')}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';
    final list = timeSlots.where((s) => s.selectedDate == ymd).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return list;
  }

  double get totalPrice {
    final selectedSlots =
        timeSlots.where((s) => selectedSlotIds.contains(s.slotId));
    return selectedSlots.fold(0.0, (sum, s) => sum + s.price);
  }

  // --- Reviews logic ---

  Future<void> loadReviews(String venueId) async {
    if (isLoadingReviews.value) return;
    try {
      isLoadingReviews.value = true;
      reviewsError.value = '';
      reviewPage.value = 1;
      final response = await (apiService as ApiServiceImpl).getReviewsByVenue(
        venueId: venueId,
        page: reviewPage.value,
        pageSize: reviewsPageSize,
      );
      reviews.assignAll(response.reviews);
      reviewTotalCount.value = response.totalCount;
      reviewAverageRating.value = response.averageRating;
      hasMoreReviews.value = response.hasMore;
      _reviewsLoaded = true;
    } catch (e) {
      reviewsError.value = 'Không thể tải đánh giá: $e';
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> loadMoreReviews() async {
    final currentVenue = venue.value;
    if (currentVenue == null) return;
    if (isLoadingMoreReviews.value || !hasMoreReviews.value) return;
    try {
      isLoadingMoreReviews.value = true;
      final nextPage = reviewPage.value + 1;
      final response = await (apiService as ApiServiceImpl).getReviewsByVenue(
        venueId: currentVenue.id,
        page: nextPage,
        pageSize: reviewsPageSize,
      );
      reviews.addAll(response.reviews);
      reviewPage.value = nextPage;
      reviewTotalCount.value = response.totalCount;
      reviewAverageRating.value = response.averageRating;
      hasMoreReviews.value = response.hasMore;
    } catch (e) {
      reviewsError.value = 'Không thể tải thêm đánh giá: $e';
    } finally {
      isLoadingMoreReviews.value = false;
    }
  }

  bool get hasReviewsLoaded => _reviewsLoaded;

  /// Lazy-load `GET /reviews/field/{id}/average-rating` for a single field.
  /// Uses an in-memory cache so repeated lookups (e.g. switching tabs)
  /// don't refetch.
  Future<FieldRatingDto?> loadFieldAverageRating(String fieldId) async {
    if (fieldRatings.containsKey(fieldId)) return fieldRatings[fieldId];
    if (isLoadingFieldRating[fieldId] == true) return null;

    isLoadingFieldRating[fieldId] = true;
    fieldRatingError.remove(fieldId);
    try {
      final dto = await reviewRepository.getFieldAverageRating(fieldId);
      fieldRatings[fieldId] = dto;
      return dto;
    } catch (e) {
      fieldRatingError[fieldId] = 'Không thể tải đánh giá sân';
      return null;
    } finally {
      isLoadingFieldRating[fieldId] = false;
    }
  }

  FieldRatingDto? ratingFor(String fieldId) => fieldRatings[fieldId];

  /// Best-effort unlock for every slot the user is currently holding on this
  /// detail screen. Called when the page is disposed, when the user deselects
  /// all slots, or when navigating away from the booking flow.
  ///
  /// Server-side, slot locking happens via `POST /bookings`. If the booking is
  /// never created, this gives the user/server a chance to free the lock.
  void unlockSelectedSlots() {
    if (_unlockDispatched) return;
    final ids = selectedSlotIds.toList(growable: false);
    if (ids.isEmpty) return;
    _unlockDispatched = true;
    // Fire-and-forget; the slot repository swallows network errors so a
    // failure here cannot affect navigation back to the previous screen.
    for (final slotId in ids) {
      slotRepository.unlockSlot(slotId);
    }
  }

  /// Public hook for the view to clear the local selection after a manual
  /// "bỏ chọn" action without leaving the page.
  void clearSelectedSlots() {
    selectedSlotIds.clear();
    _unlockDispatched = false;
  }

  void nextImage(int total) {
    if (total <= 1) return;
    final next = (currentImageIndex.value + 1) % total;
    imagePageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void previousImage(int total) {
    if (total <= 1) return;
    final prev = (currentImageIndex.value - 1 + total) % total;
    imagePageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }

  @override
  void onClose() {
    // Best-effort unlock before disposing UI controllers.
    unlockSelectedSlots();
    imagePageController.dispose();
    super.onClose();
  }
}
