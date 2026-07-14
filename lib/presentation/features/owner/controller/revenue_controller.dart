import 'package:exe101/domain/models/revenue_model.dart';
import 'package:exe101/domain/repositories/owner_management_repository.dart';
import 'package:get/get.dart';

enum RevenueRange { last7Days, last30Days, last90Days }

extension RevenueRangeX on RevenueRange {
  String get apiValue {
    switch (this) {
      case RevenueRange.last7Days:
        return 'day';
      case RevenueRange.last30Days:
        return 'day';
      case RevenueRange.last90Days:
        return 'month';
    }
  }

  String get label {
    switch (this) {
      case RevenueRange.last7Days:
        return '7 ngày';
      case RevenueRange.last30Days:
        return '30 ngày';
      case RevenueRange.last90Days:
        return '3 tháng';
    }
  }

  /// Số ngày lookback, dùng cho from-date.
  int get lookbackDays {
    switch (this) {
      case RevenueRange.last7Days:
        return 7;
      case RevenueRange.last30Days:
        return 30;
      case RevenueRange.last90Days:
        return 90;
    }
  }
}

class RevenueController extends GetxController {
  final OwnerManagementRepository ownerRepository;

  RevenueController({required this.ownerRepository});

  final isLoading = false.obs;
  final revenue = RevenueResponse.empty().obs;
  final selectedRange = RevenueRange.last30Days.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRevenue();
  }

  Future<void> loadRevenue() async {
    isLoading.value = true;
    errorMessage.value = '';
    final range = selectedRange.value;
    try {
      final now = DateTime.now();
      final from = now.subtract(Duration(days: range.lookbackDays - 1));
      final result = await ownerRepository.getOwnerRevenue(
        from: DateTime(from.year, from.month, from.day),
        to: now,
        groupBy: range.apiValue,
      );
      revenue.value = result;
    } catch (e) {
      errorMessage.value = 'Không thể tải dữ liệu doanh thu';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changeRange(RevenueRange range) async {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    await loadRevenue();
  }

  @override
  Future<void> refresh() => loadRevenue();

  double get maxRevenue {
    final list = revenue.value.groups;
    if (list.isEmpty) return 1;
    return list.map((e) => e.revenue).reduce((a, b) => a > b ? a : b);
  }
}
