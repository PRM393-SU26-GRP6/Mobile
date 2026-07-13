import 'dart:async';

import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/shared/customer_constants.dart';
import 'package:exe101/presentation/features/customer/view/orders/payment_flow_resolver.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_qr_content.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_qr_state_views.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentQRPage extends StatefulWidget {
  const PaymentQRPage({super.key});

  @override
  State<PaymentQRPage> createState() => _PaymentQRPageState();
}

class _PaymentQRPageState extends State<PaymentQRPage> {
  final String bookingId = Get.arguments['bookingId'] ?? '';
  final String venueName = Get.arguments['venueName'] ?? 'Sân bóng';
  final double totalPrice = Get.arguments['totalPrice'] ?? 0.0;
  final double paymentAmount = Get.arguments['paymentAmount'] ?? 0.0;
  final String paymentType = Get.arguments['paymentType'] ?? 'deposit';
  final PaymentMethod paymentMethod =
      Get.arguments['paymentMethod'] ?? PaymentMethod.sePay;

  bool get isDeposit => paymentType == 'deposit';

  bool get isSePay => paymentMethod == PaymentMethod.sePay;

  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  PaymentModel? _payment;
  SePayQRInfoModel? _sePayQRInfo;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _createPayment();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _createPayment() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();

      if (isSePay) {
        final payment = await _findReusableCurrentPayment(apiService);
        if (payment != null) {
          await _showPayment(payment);
          return;
        }
      }

      final payment = await _createPaymentByType(apiService);

      if (payment.id.isEmpty) {
        setState(() {
          _isError = true;
          _errorMessage =
              'Không thể tạo thanh toán - không nhận được phản hồi từ server';
          _isLoading = false;
        });
        return;
      }

      if (payment.isFailed) {
        setState(() {
          _isError = true;
          _errorMessage = 'Không thể tạo thanh toán. Vui lòng thử lại sau.';
          _isLoading = false;
        });
        return;
      }

      await _showPayment(payment);
    } on DioException catch (e) {
      if (isSePay &&
          PaymentFlowResolver.isExistingPaymentError(e, paymentType)) {
        await _reuseExistingPayment();
        return;
      }

      String errorMsg = 'Đã xảy ra lỗi';

      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response?.data as Map;
        errorMsg = data['message']?.toString() ??
            data['title']?.toString() ??
            data['errors']?.toString() ??
            'Lỗi từ server (${e.response?.statusCode})';
      } else if (e.message != null) {
        errorMsg = e.message!;
      }

      setState(() {
        _isError = true;
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Lỗi: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<PaymentModel> _createPaymentByType(ApiServiceImpl apiService) {
    if (isDeposit) {
      return apiService.createDepositPayment(
        bookingId,
        paymentMethod: paymentMethod.value,
      );
    }
    return apiService.createFinalPayment(
      bookingId,
      paymentMethod: paymentMethod.value,
    );
  }

  Future<PaymentModel?> _findReusableCurrentPayment(
    ApiServiceImpl apiService,
  ) async {
    final payments = await apiService.getPaymentsByBooking(bookingId);
    return PaymentFlowResolver.findReusablePayment(
      payments,
      paymentType: paymentType,
    );
  }

  Future<void> _showPayment(PaymentModel payment) async {
    final apiService = Get.find<ApiServiceImpl>();

    _payment = payment;

    if (isSePay) {
      final qrInfo = await apiService.getSePayQRInfo(payment.id);
      if (!mounted) return;
      setState(() {
        _sePayQRInfo = qrInfo;
      });
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isError = false;
      _errorMessage = '';
    });

    if (isSePay) {
      _startPaymentStatusPolling();
    }
  }

  Future<void> _reuseExistingPayment() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();
      final payment = await _findReusableCurrentPayment(apiService);

      if (payment == null) {
        if (!mounted) return;
        setState(() {
          _isError = true;
          _errorMessage =
              'Khoản thanh toán đang được xử lý hoặc đã thanh toán.';
          _isLoading = false;
        });
        return;
      }

      await _showPayment(payment);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _errorMessage = 'Không thể tải lại mã QR của thanh toán đang xử lý.';
        _isLoading = false;
      });
    }
  }

  void _startPaymentStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted || _payment == null) {
        timer.cancel();
        return;
      }

      try {
        final apiService = Get.find<ApiServiceImpl>();
        final updatedPayment = await apiService.getPaymentById(_payment!.id);

        if (updatedPayment != null && updatedPayment.isSuccess && mounted) {
          timer.cancel();
          await showPaymentSuccessDialog();
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isDeposit
              ? 'Thanh toán cọc ${getPaymentMethodText(paymentMethod)}'
              : 'Thanh toán ${getPaymentMethodText(paymentMethod)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const PaymentQrLoadingView();
    }

    if (_isError) {
      return PaymentQrErrorView(
        message: _errorMessage,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _isError = false;
          });
          _createPayment();
        },
      );
    }
    return PaymentQrContent(
      paymentMethod: paymentMethod,
      isDeposit: isDeposit,
      isSePay: isSePay,
      venueName: venueName,
      paymentAmount: paymentAmount,
      payment: _payment,
      sePayQRInfo: _sePayQRInfo,
      onCheckStatus: _checkPaymentStatusNow,
    );
  }

  Future<void> _checkPaymentStatusNow() async {
    if (_payment == null) return;

    try {
      final apiService = Get.find<ApiServiceImpl>();
      final updatedPayment = await apiService.getPaymentById(_payment!.id);

      if (updatedPayment != null && updatedPayment.isSuccess) {
        _pollingTimer?.cancel();
        await showPaymentSuccessDialog();
        return;
      }

      Get.snackbar(
        'Dang cho thanh toan',
        'He thong chua nhan duoc giao dich. Vui long thu lai sau.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (_) {
      Get.snackbar(
        'Loi',
        'Khong the kiem tra trang thai thanh toan.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
