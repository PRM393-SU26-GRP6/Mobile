import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';
import 'package:exe101/domain/repositories/review_repository.dart';
import 'package:exe101/domain/repositories/slot_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:exe101/core/theme/app_theme.dart';

part 'venue_detail_review_actions.dart';
part 'venue_detail_selection_actions.dart';

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
