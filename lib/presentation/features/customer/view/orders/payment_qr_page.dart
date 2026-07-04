import 'dart:async';

import 'package:dio/dio.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final PaymentMethod paymentMethod = Get.arguments['paymentMethod'] ?? PaymentMethod.sePay;

  bool get isDeposit => paymentType == 'deposit';
  bool get isFinal => paymentType == 'final';

  // Only SePay uses QR
  bool get isSePay => paymentMethod == PaymentMethod.sePay;
  // MoMo and VNPay use paymentUrl redirect
  bool get needsRedirect =>
      paymentMethod == PaymentMethod.moMo || paymentMethod == PaymentMethod.vnPay;

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

  String _buildSePayImageUrl() {
    return _sePayQRInfo!.qrUrl;
  }

  Future<void> _createPayment() async {
    try {
      final apiService = Get.find<ApiServiceImpl>();

      // DEBUG
      debugPrint('[PaymentQR] paymentMethod: $paymentMethod, isSePay: $isSePay');
      debugPrint('[PaymentQR] paymentType: $paymentType, isDeposit: $isDeposit');

      // Create payment based on type (deposit or final)
      final payment = isDeposit
          ? await apiService.createDepositPayment(
              bookingId,
              paymentMethod: paymentMethod.value,
            )
          : await apiService.createFinalPayment(
              bookingId,
              paymentMethod: paymentMethod.value,
            );

      debugPrint('[PaymentQR] Payment created - id: ${payment.id}');

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

      // For SePay: Get QR info
      // For MoMo/VNPay: Use paymentUrl from the payment object
      if (isSePay) {
        debugPrint('[PaymentQR] Calling getSePayQRInfo for payment: ${payment.id}');
        final qrInfo = await apiService.getSePayQRInfo(payment.id);
        debugPrint('[PaymentQR] QR Info received: ${qrInfo?.qrUrl}');
        setState(() {
          _sePayQRInfo = qrInfo;
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Start polling for payment status (only for SePay auto-confirm)
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
          _showPaymentSuccessDialog();
        }
      } catch (_) {
        // Silent fail for polling
      }
    });
  }

  void _showPaymentSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Thanh toán thành công'),
          ],
        ),
        content: const Text('Thanh toán của bạn đã được xác nhận. Cảm ơn bạn!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(result: true);
              if (Get.isRegistered<BookingController>()) {
                Get.find<BookingController>().refreshBookings();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _openPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Lỗi',
          'Không thể mở trang thanh toán',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể mở trang thanh toán: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
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
              ? 'Thanh toán cọc ${_getPaymentMethodText(paymentMethod)}'
              : 'Thanh toán ${_getPaymentMethodText(paymentMethod)}',
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
          _buildMethodInfoBanner(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildQRCard(),
          const SizedBox(height: 16),
          _buildInstructions(),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildMethodInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _getMethodIcon(paymentMethod),
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit
                      ? 'Thanh toán cọc - ${_getPaymentMethodText(paymentMethod)}'
                      : 'Thanh toán - ${_getPaymentMethodText(paymentMethod)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _getMethodDescription(paymentMethod),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Đổi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sePay:
        return Icons.qr_code_2;
      case PaymentMethod.moMo:
        return Icons.account_balance_wallet;
      case PaymentMethod.vnPay:
        return Icons.payment;
      case PaymentMethod.cash:
        return Icons.payments;
    }
  }

  String _getMethodDescription(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.sePay:
        return 'Quét mã QR để thanh toán';
      case PaymentMethod.moMo:
        return 'Thanh toán qua ví MoMo';
      case PaymentMethod.vnPay:
        return 'Thanh toán qua VNPay';
      case PaymentMethod.cash:
        return 'Thanh toán trực tiếp tại sân';
    }
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sân',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                venueName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDeposit ? 'Số tiền cọc' : 'Số tiền thanh toán',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${paymentAmount.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (_payment != null) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mã thanh toán',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _payment!.id));
                    Get.snackbar(
                      'Đã sao chép',
                      'Mã thanh toán đã được sao chép',
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        _payment!.id.substring(0, 8).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phương thức',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _getPaymentMethodText(_payment!.paymentMethod),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.moMo:
        return 'MoMo';
      case PaymentMethod.vnPay:
        return 'VNPay';
      case PaymentMethod.sePay:
        return 'SePay QR';
    }
  }

  Widget _buildQRCard() {
    // For MoMo/VNPay: show redirect info instead of QR
    if (needsRedirect) {
      return _buildRedirectCard();
    }

    // DEBUG
    debugPrint('[PaymentQR] _buildQRCard - _sePayQRInfo: ${_sePayQRInfo?.qrUrl ?? "null"}');
    debugPrint('[PaymentQR] _buildQRCard - isSePay: $isSePay');

    // Only show QR for SePay
    if (_sePayQRInfo == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Đang tải thông tin thanh toán...'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // Mobile: WebView shows full VietQR page
          // Web: QrImageView generates QR from URL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.network(
                    _buildSePayImageUrl(),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 380,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return QrImageView(
                        data: _sePayQRInfo!.qrUrl,
                        version: QrVersions.auto,
                        size: 260,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (_sePayQRInfo!.bankInfo != null) ...[
                  _buildBankRow('Ngân hàng', _sePayQRInfo!.bankInfo!.bankId.toUpperCase()),
                  _buildBankRow('STK', _sePayQRInfo!.bankInfo!.accountNo),
                  _buildBankRow('Tên', _sePayQRInfo!.bankInfo!.accountName),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${paymentAmount.toStringAsFixed(0)}đ',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (_sePayQRInfo!.bankInfo != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildBankRow('Ngân hàng', _sePayQRInfo!.bankInfo!.bankId),
                  const SizedBox(height: 4),
                  _buildBankRow('Số tài khoản', _sePayQRInfo!.bankInfo!.accountNo),
                  const SizedBox(height: 4),
                  _buildBankRow('Tên TK', _sePayQRInfo!.bankInfo!.accountName),
                ],
              ),
            ),
          ],
          if (_sePayQRInfo!.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Nội dung: ${_sePayQRInfo!.description}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRedirectCard() {
    final paymentUrl = _payment?.paymentUrl ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getMethodIcon(paymentMethod),
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Thanh toán qua ${_getPaymentMethodText(paymentMethod)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMethodDescription(paymentMethod),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${paymentAmount.toStringAsFixed(0)}đ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn sẽ được chuyển đến trang thanh toán. Vui lòng hoàn tất và quay lại ứng dụng.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (paymentUrl.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openPaymentUrl(paymentUrl),
                icon: const Icon(Icons.open_in_new),
                label: Text('Mở ${_getPaymentMethodText(paymentMethod)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBankRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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
