part of '../api_service.dart';

extension FieldBookingApiFacade on ApiServiceImpl {
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
      slotScheduleService.updateFieldSchedule(fieldId: fieldId, rows: rows);
  Future<void> updateSlotStatus(String slotId, String status) =>
      slotScheduleService.updateSlotStatus(slotId, status);

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

  Future<Map<String, dynamic>> getOwnerStats() async {
    final response = await dio.get<Map<String, dynamic>>(
      '${dio.options.baseUrl}/api/v1/owner/stats',
      options: Options(headers: await authHeaders()),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, String>> authHeaders() => authService.authHeaders();
}
