import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingManagementController extends GetxController {
  final ApiServiceImpl apiService;

  BookingManagementController({required this.apiService});

  final bookings = <BookingDto>[].obs;
  final pendingBookings = <BookingDto>[].obs;
  final selectedFilter = 'all'.obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  final List<Map<String, dynamic>> filterOptions = [
    {'value': 'all', 'label': 'Tất cả'},
    {'value': 'Pending', 'label': 'Chờ duyệt'},
    {'value': 'Accepted', 'label': 'Đã xác nhận'},
    {'value': 'Completed', 'label': 'Hoàn thành'},
    {'value': 'Cancelled', 'label': 'Đã hủy'},
    {'value': 'Rejected', 'label': 'Từ chối'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadBookings();
    loadPendingBookings();
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    try {
      final status = selectedFilter.value == 'all' ? null : selectedFilter.value;
      final result = await apiService.getOwnerBookings(status: status);
      bookings.assignAll(result);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách đặt sân');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingBookings() async {
    try {
      final result = await apiService.getPendingBookings();
      pendingBookings.assignAll(result);
    } catch (e) {
      debugPrint('Error loading pending bookings: $e');
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadBookings();
  }

  void setTab(int index) {
    selectedTab.value = index;
  }

  Future<void> acceptBooking(String bookingId) async {
    try {
      await apiService.acceptBooking(bookingId);
      await loadBookings();
      await loadPendingBookings();
      Get.snackbar('Thành công', 'Đã chấp nhận đặt sân');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chấp nhận đặt sân');
    }
  }

  Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      await apiService.rejectBooking(bookingId, rejectionReason: reason);
      await loadBookings();
      await loadPendingBookings();
      Get.snackbar('Thành công', 'Đã từ chối đặt sân');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể từ chối đặt sân');
    }
  }

  Future<void> completeBooking(String bookingId) async {
    try {
      await apiService.completeBooking(bookingId);
      await loadBookings();
      Get.snackbar('Thành công', 'Đã hoàn thành đặt sân');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể hoàn thành đặt sân');
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadBookings(), loadPendingBookings()]);
  }

  int get pendingCount => pendingBookings.length;

  List<BookingDto> get filteredBookings {
    if (selectedFilter.value == 'all') {
      return bookings;
    }
    return bookings
        .where((b) => b.bookingStatus == selectedFilter.value)
        .toList();
  }

  List<BookingDto> get todayBookings {
    final now = DateTime.now();
    return bookings.where((b) {
      return b.startTime.year == now.year &&
          b.startTime.month == now.month &&
          b.startTime.day == now.day;
    }).toList();
  }
}
