import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:get/get.dart';

class PaymentHistoryController extends GetxController {
  final ApiService apiService;

  final payments = <PaymentModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final error = ''.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  PaymentHistoryController({required this.apiService});

  @override
  void onInit() {
    super.onInit();
    loadPayments();
  }

  Future<void> loadPayments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
      payments.clear();
    }

    if (!hasMore.value) return;

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      if (apiService is ApiServiceImpl) {
        final result = await (apiService as ApiServiceImpl).getPaymentHistory(
          pageNumber: _currentPage,
          pageSize: _pageSize,
        );

        if (result.length < _pageSize) {
          hasMore.value = false;
        }

        if (_currentPage == 1) {
          payments.value = result;
        } else {
          payments.addAll(result);
        }
        _currentPage++;
      }
    } catch (e) {
      error.value = 'Không thể tải lịch sử thanh toán: $e';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshPayments() => loadPayments(refresh: true);
}
