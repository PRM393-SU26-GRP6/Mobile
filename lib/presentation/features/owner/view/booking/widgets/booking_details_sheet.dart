import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/owner/controller/booking_management_controller.dart';
import 'package:exe101/presentation/features/owner/view/booking/widgets/owner_booking_details_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showBookingDetailsSheet(
  BookingDto booking, {
  bool refreshFromApi = false,
}) async {
  var resolved = booking;
  if (refreshFromApi) {
    final fresh = await Get.find<BookingManagementController>()
        .fetchBookingDetail(booking.id);
    if (fresh != null) resolved = fresh;
  }
  return Get.bottomSheet<void>(
    OwnerBookingDetailsContent(booking: resolved),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
