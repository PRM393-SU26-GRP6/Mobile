import 'package:dio/dio.dart';
import 'package:exe101/core/config/env.dart';
import 'package:exe101/data/remote/_base_api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';

/// All payment endpoints (customer + SePay integration + webhooks).
///
/// Customer:
/// - GET  /api/v1/payments/booking/{bookingId}
/// - GET  /api/v1/payments/history
/// - POST /api/v1/payments/deposit
/// - POST /api/v1/payments/final
/// - GET  /api/v1/payments/{id}
/// - GET  /api/v1/payments/{id}/sepay-qr
/// - GET  /api/v1/payments/{id}/sepay-checkout
///
/// Webhook (no auth):
/// - POST /api/v1/payments/webhook/sepay
/// - POST /api/v1/payments/callback/{gateway}
class PaymentApiService extends BaseApiService {
  PaymentApiService(super.dio);

  Future<List<PaymentModel>> getPaymentsByBooking(String bookingId) async {
    final headers = await authHeaders();
    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/payments/booking/$bookingId',
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final data = response.data!;
    if (data is List) {
      return data
          .map((json) =>
              PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    }
    if (data is! Map<String, dynamic>) return [];
    final listData = data['data'];
    if (listData is! List) return [];
    return listData
        .map((json) =>
            PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<PaymentModel> createDepositPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/deposit',
      data: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
      },
      options: Options(headers: headers),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data?['message'] ?? 'Payment creation failed',
      );
    }

    final data = response.data?['data'] ?? response.data ?? {};
    return PaymentModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<PaymentModel> createFinalPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) async {
    final headers = await authJsonHeaders();
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/final',
      data: {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
      },
      options: Options(headers: headers),
    );

    final data = response.data?['data'] ?? response.data ?? {};
    return PaymentModel.fromJson(data is Map<String, dynamic> ? data : {});
  }

  Future<PaymentModel> createFullPayment(
    String bookingId, {
    String paymentMethod = 'SePay',
  }) =>
      createFinalPayment(bookingId, paymentMethod: paymentMethod);

  Future<SePayQRInfoModel?> getSePayQRInfo(String paymentId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId/sepay-qr',
      options: Options(headers: headers),
    );

    if (response.data == null) return null;
    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;
    return SePayQRInfoModel.fromJson(payload);
  }

  Future<PaymentModel?> getPaymentById(String paymentId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId',
      options: Options(headers: headers),
    );

    if (response.data == null) return null;
    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;
    return PaymentModel.fromJson(payload);
  }

  Future<SePayCheckoutFormModel?> getSePayCheckout(String paymentId) async {
    final headers = await authHeaders();
    final response = await dio.get<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/$paymentId/sepay-checkout',
      options: Options(headers: headers),
    );

    if (response.data == null) return null;
    final data = response.data!;
    final payload = data['data'] ?? data;
    if (payload is! Map<String, dynamic>) return null;
    return SePayCheckoutFormModel.fromJson(payload);
  }

  Future<Map<String, dynamic>?> handleSePayWebhook({
    required String transferType,
    required String transferAmount,
    required String transferDate,
    required String bankAccount,
    String? reference,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/webhook/sepay',
      data: {
        'transferType': transferType,
        'transferAmount': transferAmount,
        'transferDate': transferDate,
        'bankAccount': bankAccount,
        if (reference != null) 'reference': reference,
      },
      options: Options(headers: jsonHeaders()),
    );

    if (response.data == null) return null;
    return response.data;
  }

  Future<Map<String, dynamic>?> handlePaymentCallback({
    required String gateway,
    required Map<String, dynamic> callbackData,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '${Env.baseUrl}/api/v1/payments/callback/$gateway',
      data: callbackData,
      options: Options(headers: jsonHeaders()),
    );

    if (response.data == null) return null;
    return response.data;
  }

  Future<List<PaymentModel>> getPaymentHistory({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final headers = await authHeaders();
    final params = <String, dynamic>{
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final response = await dio.get<dynamic>(
      '${Env.baseUrl}/api/v1/payments/history',
      queryParameters: params,
      options: Options(headers: headers),
    );

    if (response.data == null) return [];
    final list = BaseApiService.extractList(response.data);
    if (list.isEmpty && response.data is Map<String, dynamic>) {
      final inner = BaseApiService.extractList(
          (response.data as Map<String, dynamic>)['data']);
      if (inner.isNotEmpty) {
        return inner
            .map((json) =>
                PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
    }
    return list
        .map((json) =>
            PaymentModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
