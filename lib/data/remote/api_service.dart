import 'package:dio/dio.dart';
import 'package:exe101/data/remote/auth/auth_api_service.dart';
import 'package:exe101/data/remote/booking/booking_api_service.dart';
import 'package:exe101/data/remote/chat/chat_api_service.dart';
import 'package:exe101/data/remote/shared/discount_api_service.dart';
import 'package:exe101/data/remote/notification/notification_api_service.dart';
import 'package:exe101/data/remote/payment/payment_api_service.dart';
import 'package:exe101/data/remote/shared/review_api_service.dart';
import 'package:exe101/data/remote/schedule/slot_schedule_api_service.dart';
import 'package:exe101/data/remote/auth/user_api_service.dart';
import 'package:exe101/data/remote/venue/venue_api_service.dart';
import 'package:exe101/data/remote/venue/venue_owner_api_service.dart';
import 'package:exe101/data/remote/venue/field_api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/models/chat_model.dart';
import 'package:exe101/domain/models/discount_model.dart';
import 'package:exe101/domain/models/field_model.dart';
import 'package:exe101/domain/models/field_schedule_model.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:exe101/domain/models/notification_model.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/domain/models/review_model.dart';
import 'package:exe101/domain/models/time_slot_model.dart';
import 'package:exe101/domain/models/venue_model.dart';

/// Base class kept only to preserve the public type name. The former concrete
/// logic (GET/POST/PUT/DELETE/PATCH helpers) is no longer used by anyone but
/// the legacy facade, so the helpers have been dropped.
class ApiService {
  final Dio dio;
  ApiService(this.dio);
}

/// Backwards-compatible facade for the previously monolithic `ApiServiceImpl`.
///
/// Each domain now lives in its own focused service under `data/remote/`. This
/// facade:
/// 1. Owns the lifetime of those focused services.
/// 2. Re-exposes every old method signature so the existing ~30 callers
///    (controllers, bindings, views, repositories) keep working unchanged.
///
/// New code should depend on the focused services directly via GetX bindings
/// instead of going through this facade.
class ApiServiceImpl extends ApiService {
  final AuthApiService authService;
  final UserApiService userService;
  final VenueApiService venueService;
  final VenueOwnerApiService venueOwnerService;
  final FieldApiService fieldService;
  final BookingApiService bookingService;
  final SlotScheduleApiService slotScheduleService;
  final PaymentApiService paymentService;
  final NotificationApiService notificationService;
  final ChatApiService chatService;
  final DiscountApiService discountService;
  final ReviewApiService reviewService;

  ApiServiceImpl(super.dio)
      : authService = AuthApiService(dio),
        userService = UserApiService(dio),
        venueService = VenueApiService(dio),
        venueOwnerService = VenueOwnerApiService(dio),
        fieldService = FieldApiService(dio),
        bookingService = BookingApiService(dio),
        slotScheduleService = SlotScheduleApiService(dio),
        paymentService = PaymentApiService(dio),
        notificationService = NotificationApiService(dio),
        chatService = ChatApiService(dio),
        discountService = DiscountApiService(dio),
        reviewService = ReviewApiService(dio);

  // --- Auth ---

  Future<LoginResponseModel> login(String email, String password) =>
      authService.login(email, password);

  Future<LoginResponseModel> registerCustomer({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) =>
      authService.registerCustomer(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

  Future<LoginResponseModel> registerOwner({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String confirmPassword,
  }) =>
      authService.registerOwner(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        confirmPassword: confirmPassword,
      );

  Future<LoginResponseModel> verifyOtp(String email, String otp) =>
      authService.verifyOtp(email, otp);

  Future<void> resendOtp(String email) => authService.resendOtp(email);

  Future<void> logout() => authService.logout();

  Future<bool> refreshToken() => authService.refreshToken();

  Future<String?> getAccessToken() => authService.getAccessToken();

  Future<String?> getUserRole() => authService.getUserRole();

  Future<String?> getUserId() => authService.getUserId();

  // --- Venue ---

  Future<List<VenueModel>> getVenues({
    String? q,
    String? fieldType,
    String? amenityIds,
    double? minRating,
    double? priceMin,
    double? priceMax,
    double? userLatitude,
    double? userLongitude,
    double? radiusInKm,
    String? sort,
    int page = 1,
    int pageSize = 20,
  }) =>
      venueService.getVenues(
        q: q,
        fieldType: fieldType,
        amenityIds: amenityIds,
        minRating: minRating,
        priceMin: priceMin,
        priceMax: priceMax,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        radiusInKm: radiusInKm,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

  Future<List<VenueModel>> searchVenues({
    String? q,
    int page = 1,
    int pageSize = 20,
  }) =>
      venueService.searchVenues(q: q, page: page, pageSize: pageSize);

  Future<List<AmenityModel>> getAllAmenities() =>
      venueService.getAllAmenities();

  Future<List<FootballFieldDto>> getFieldsByVenue(String venueId) =>
      venueService.getFieldsByVenue(venueId);

  Future<VenueModel?> getVenueById(String id) => venueService.getVenueById(id);

  Future<List<VenueModel>> getMyVenues({
    bool? isActive,
    int page = 1,
    int pageSize = 10,
  }) =>
      venueOwnerService.getMyVenues(
          isActive: isActive, page: page, pageSize: pageSize);

  Future<VenueModel> createVenue({
    required String venueName,
    required String address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) =>
      venueOwnerService.createVenue(
        venueName: venueName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        openingHours: openingHours,
        phoneContact: phoneContact,
      );

  Future<VenueModel> updateVenue({
    required String venueId,
    String? venueName,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? openingHours,
    String? phoneContact,
  }) =>
      venueOwnerService.updateVenue(
        venueId: venueId,
        venueName: venueName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        description: description,
        openingHours: openingHours,
        phoneContact: phoneContact,
      );

  Future<void> updateVenueStatus(String venueId, bool isActive) =>
      venueOwnerService.updateVenueStatus(venueId, isActive);

  // --- Field ---

  Future<FieldModel> createField({
    required String venueId,
    required String fieldName,
    required String fieldType,
    String? description,
    double? priceMorning,
    double? priceAfternoon,
    double? priceEvening,
    List<String>? amenities,
  }) =>
      fieldService.createField(
        venueId: venueId,
        fieldName: fieldName,
        fieldType: fieldType,
        description: description,
        priceMorning: priceMorning,
        priceAfternoon: priceAfternoon,
        priceEvening: priceEvening,
        amenities: amenities,
      );

  Future<FieldModel> updateField({
    required String fieldId,
    String? fieldName,
    String? fieldType,
    String? description,
    double? priceMorning,
    double? priceAfternoon,
    double? priceEvening,
    List<String>? amenities,
    bool? isActive,
  }) =>
      fieldService.updateField(
        fieldId: fieldId,
        fieldName: fieldName,
        fieldType: fieldType,
        description: description,
        priceMorning: priceMorning,
        priceAfternoon: priceAfternoon,
        priceEvening: priceEvening,
        amenities: amenities,
        isActive: isActive,
      );

  Future<void> updateFieldStatus(String fieldId, bool isActive) =>
      fieldService.updateFieldStatus(fieldId, isActive);

  Future<List<FieldModel>> getFieldsByOwner() =>
      fieldService.getFieldsByOwner();

  Future<FieldModel?> getFieldById(String fieldId) =>
      fieldService.getFieldById(fieldId);

  Future<FieldModel> createOwnerField({
    required String venueId,
    required String fieldName,
    required String fieldType,
    String? description,
    double? priceMorning,
    double? priceAfternoon,
    double? priceEvening,
    List<String>? amenities,
  }) =>
      venueOwnerService.createOwnerField(
        venueId: venueId,
        fieldName: fieldName,
        fieldType: fieldType,
        description: description,
        priceMorning: priceMorning,
        priceAfternoon: priceAfternoon,
        priceEvening: priceEvening,
        amenities: amenities,
      );

  Future<List<FieldModel>> getOwnerFieldsByVenue(String venueId) =>
      venueOwnerService.getOwnerFieldsByVenue(venueId);

  // --- Slot / schedule ---

  Future<List<TimeSlotDto>> getAvailableSlots({
    required String fieldId,
    required String date,
  }) =>
      slotScheduleService.getAvailableSlots(fieldId: fieldId, date: date);

  Future<List<TimeSlotDto>> getSlotsByField(String fieldId) =>
      slotScheduleService.getSlotsByField(fieldId);

  Future<void> bulkCreateSlots({
    required String fieldId,
    required BulkCreateSlotsDto slotsDto,
  }) =>
      slotScheduleService.bulkCreateSlots(
        fieldId: fieldId,
        slotsDto: slotsDto,
      );

  Future<List<FieldScheduleDto>> getFieldSchedule(String fieldId) =>
      slotScheduleService.getFieldSchedule(fieldId);

  Future<List<FieldScheduleDto>> updateFieldSchedule({
    required String fieldId,
    required List<FieldScheduleRowDto> rows,
  }) =>
      slotScheduleService.updateFieldSchedule(
        fieldId: fieldId,
        rows: rows,
      );

  Future<void> updateSlotStatus(String slotId, String status) =>
      slotScheduleService.updateSlotStatus(slotId, status);

  // --- Booking ---

  Future<BookingDto> createBooking({
    required List<String> slotIds,
    required String discountCode,
    required String note,
  }) =>
      bookingService.createBooking(
        slotIds: slotIds,
        discountCode: discountCode,
        note: note,
      );

  Future<List<BookingDto>> getBookingHistory({
    String? status,
    String? from,
    String? to,
    int page = 1,
    int pageSize = 20,
  }) =>
      bookingService.getBookingHistory(
        status: status,
        from: from,
        to: to,
        page: page,
        pageSize: pageSize,
      );

  Future<BookingDto?> getBookingById(String bookingId) =>
      bookingService.getBookingById(bookingId);

  Future<void> cancelBooking(
    String bookingId, {
    String? cancellationReason,
  }) =>
      bookingService.cancelBooking(
        bookingId,
        cancellationReason: cancellationReason,
      );

  Future<List<BookingDto>> getOwnerBookings({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) =>
      bookingService.getOwnerBookings(
        status: status,
        page: page,
        pageSize: pageSize,
      );

  Future<List<BookingDto>> getPendingBookings() =>
      bookingService.getPendingBookings();

  Future<void> acceptBooking(String bookingId) =>
      bookingService.acceptBooking(bookingId);

  Future<void> rejectBooking(
    String bookingId, {
    String? rejectionReason,
  }) =>
      bookingService.rejectBooking(
        bookingId,
        rejectionReason: rejectionReason,
      );

  Future<void> completeBooking(String bookingId) =>
      bookingService.completeBooking(bookingId);

  Future<void> updateBookingStatus(String bookingId, String status) =>
      bookingService.updateBookingStatus(bookingId, status);

  /// Legacy stats endpoint. Already covered by `OwnerStatsApiService` but kept
  /// on the facade for any caller that has not migrated yet.
  Future<Map<String, dynamic>> getOwnerStats() async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${dio.options.baseUrl}/api/v1/owner/stats',
      options: Options(headers: headers),
    );
    if (response.data == null) return <String, dynamic>{};
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};
  }

  Future<Map<String, String>> authHeaders() => authService.authHeaders();

  // --- Payment ---

  Future<List<PaymentModel>> getPaymentsByBooking(String bookingId) =>
      paymentService.getPaymentsByBooking(bookingId);

  Future<PaymentModel> createDepositPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createDepositPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );

  Future<PaymentModel> createFinalPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createFinalPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );

  Future<PaymentModel> createFullPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      paymentService.createFullPayment(
        bookingId,
        paymentMethod: paymentMethod,
      );

  Future<SePayQRInfoModel?> getSePayQRInfo(String paymentId) =>
      paymentService.getSePayQRInfo(paymentId);

  Future<PaymentModel?> getPaymentById(String paymentId) =>
      paymentService.getPaymentById(paymentId);

  Future<SePayCheckoutFormModel?> getSePayCheckout(String paymentId) =>
      paymentService.getSePayCheckout(paymentId);

  Future<Map<String, dynamic>?> handleSePayWebhook({
    required String transferType,
    required String transferAmount,
    required String transferDate,
    required String bankAccount,
    String? reference,
  }) =>
      paymentService.handleSePayWebhook(
        transferType: transferType,
        transferAmount: transferAmount,
        transferDate: transferDate,
        bankAccount: bankAccount,
        reference: reference,
      );

  Future<Map<String, dynamic>?> handlePaymentCallback({
    required String gateway,
    required Map<String, dynamic> callbackData,
  }) =>
      paymentService.handlePaymentCallback(
        gateway: gateway,
        callbackData: callbackData,
      );

  Future<List<PaymentModel>> getPaymentHistory({
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      paymentService.getPaymentHistory(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  // --- Chat ---

  Future<List<ChatRoomModel>> getChatRooms({
    int pageNumber = 1,
    int pageSize = 20,
  }) =>
      chatService.getChatRooms(pageNumber: pageNumber, pageSize: pageSize);

  Future<ChatRoomModel> createChatRoom(CreateChatRoomRequest request) =>
      chatService.createChatRoom(request);

  Future<List<MessageModel>> getChatMessages({
    required String roomId,
    int pageNumber = 1,
    int pageSize = 50,
  }) =>
      chatService.getChatMessages(
        roomId: roomId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

  Future<MessageModel> sendMessage({
    required String roomId,
    required String messageText,
  }) =>
      chatService.sendMessage(roomId: roomId, messageText: messageText);

  Future<void> markChatAsRead(String roomId) =>
      chatService.markChatAsRead(roomId);

  // --- User profile ---

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

  // --- Notification ---

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

  // --- Review ---

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

  Future<List<ReviewModel>> getMyReviews() => reviewService.getMyReviews();

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

  // --- Discount ---

  Future<ValidateDiscountResponseDto?> validateDiscount(
          ValidateDiscountRequestDto request) =>
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
}
