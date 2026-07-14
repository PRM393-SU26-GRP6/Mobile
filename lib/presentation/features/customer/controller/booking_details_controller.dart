import 'package:exe101/domain/models/booking_model.dart';
import 'package:exe101/domain/repositories/booking_repository.dart';
import 'package:get/get.dart';

class BookingDetailsController extends GetxController {
  final BookingRepository bookingRepository;

  BookingDetailsController({required this.bookingRepository});

  Future<BookingDto?> load(String bookingId) {
    return bookingRepository.getById(bookingId);
  }
}
