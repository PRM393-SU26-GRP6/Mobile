import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_details_controller.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_content.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/customer_booking_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomerBookingDetailsSheet(String bookingId) {
  return Get.bottomSheet<void>(
    _CustomerBookingDetailsSheet(bookingId: bookingId),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class _CustomerBookingDetailsSheet extends StatelessWidget {
  final String bookingId;

  const _CustomerBookingDetailsSheet({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: FutureBuilder<BookingDto?>(
        future: Get.find<BookingDetailsController>().load(bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 260,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return ErrorContent(onClose: Get.back);
          }

          return CustomerBookingDetailsContent(booking: snapshot.data!);
        },
      ),
    );
  }
}
