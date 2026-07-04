import 'dart:async';

import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/shared/customer_constants.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_info_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_method_banner.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_redirect_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_success_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/sepay_qr_card.dart';
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

      final payment = isDeposit
          ? await apiService.createDepositPayment(
              bookingId,
              paymentMethod: paymentMethod.value,
            )
          : await apiService.createFinalPayment(
              bookingId,
              paymentMethod: paymentMethod.value,
            );

      if (payment.id.isEmpty) {
        setState(() {
          _isError = true;
          _errorMessage = 'Không thể tạo thanh toán - không nhận được phản hồi từ server';
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

      _payment = payment;

      if (isSePay) {
        final qrInfo = await apiService.getSePayQRInfo(payment.id);
        setState(() {
          _sePayQRInfo = qrInfo;
        });
      }

      setState(() {
        _isLoading = false;
      });

      if (isSePay) {
        _startPaymentStatusPolling();
      }
    } on DioException catch (e) {
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Đang tạo thanh toán...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('Quay lại'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _isError = false;
                      });
                      _createPayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          PaymentMethodBanner(
            paymentMethod: paymentMethod,
            isDeposit: isDeposit,
          ),
          const SizedBox(height: 16),
          PaymentInfoCard(
            venueName: venueName,
            paymentAmount: paymentAmount,
            isDeposit: isDeposit,
            payment: _payment,
          ),
          const SizedBox(height: 16),
          if (isSePay) SePayQrCard(qrInfo: _sePayQRInfo),
          if (!isSePay)
            PaymentRedirectCard(
              payment: _payment,
              paymentMethodText: getPaymentMethodText(paymentMethod),
              description: getPaymentMethodDescription(paymentMethod),
            ),
          const SizedBox(height: 16),
          if (isSePay) _buildInstructions(),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Hướng dẫn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInstructionItem('1', 'Mở ứng dụng ngân hàng hoặc ví điện tử'),
          _buildInstructionItem('2', 'Quét mã QR hoặc sao chép số tài khoản'),
          _buildInstructionItem('3', 'Thanh toán đúng số tiền hiển thị'),
          _buildInstructionItem('4', 'Hệ thống sẽ tự động xác nhận sau khi thanh toán'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final apiService = Get.find<ApiServiceImpl>();
            await apiService.updateBookingStatus(bookingId, 'deposited');

            if (Get.isRegistered<BookingController>()) {
              Get.find<BookingController>().refreshBookings();
            }
            Get.back(result: true);
            Get.snackbar(
              'Thành công',
              'Đã xác nhận đặt cọc thành công',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Lỗi',
              'Không thể xác nhận. Vui lòng thử lại.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Xác nhận',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
