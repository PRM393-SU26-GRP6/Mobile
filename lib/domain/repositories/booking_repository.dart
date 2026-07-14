import 'package:exe101/data/remote/booking/booking_api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';

class BookingRepository {
  final BookingApiService bookingApiService;

  BookingRepository({required this.bookingApiService});

  Future<BookingDto?> getById(String bookingId) {
    return bookingApiService.getBookingById(bookingId);
  }
}
