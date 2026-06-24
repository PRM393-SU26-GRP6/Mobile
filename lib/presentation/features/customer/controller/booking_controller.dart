import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final ApiService apiService;

  final bookings = <BookingDto>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final error = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;
  String? _status;
  String? _from;
  String? _to;

  BookingController({required this.apiService});

  Future<void> loadBookings(
      {bool refresh = false, String? status, String? from, String? to}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      bookings.clear();
    }

    // update filters only when provided (null means keep existing)
    if (status != null) _status = status;
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
