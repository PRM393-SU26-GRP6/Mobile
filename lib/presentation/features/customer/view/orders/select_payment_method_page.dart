import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/cash_payment_confirm_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_method_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_method_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  State<SelectPaymentMethodPage> createState() =>
      _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  final String bookingId = Get.arguments['bookingId'] ?? '';
  final String venueName = Get.arguments['venueName'] ?? 'Sân bóng';
  final double totalPrice = Get.arguments['totalPrice'] ?? 0;
  final double paymentAmount = Get.arguments['paymentAmount'] ?? 0.0;
  final String paymentType = Get.arguments['paymentType'] ?? 'deposit';

  bool get isDeposit => paymentType == 'deposit';

  PaymentMethod _selectedMethod = PaymentMethod.sePay;

  final List<PaymentMethodOption> _methods = [
    PaymentMethodOption(
      method: PaymentMethod.sePay,
      name: 'SePay QR',
      description: 'Quét mã QR để thanh toán',
      icon: Icons.qr_code_2,
      color: const Color(0xFF6C63FF),
    ),
    PaymentMethodOption(
      method: PaymentMethod.moMo,
      name: 'MoMo',
      description: 'Thanh toán qua ví MoMo',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFFA50064),
    ),
    PaymentMethodOption(
      method: PaymentMethod.vnPay,
      name: 'VNPay',
      description: 'Thanh toán qua VNPay',
      icon: Icons.payment,
      color: const Color(0xFF0066B3),
    ),
    PaymentMethodOption(
      method: PaymentMethod.cash,
      name: 'Tiền mặt',
      description: 'Thanh toán trực tiếp tại sân',
      icon: Icons.payments,
      color: const Color(0xFF16A34A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chọn phương thức thanh toán',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildPriceInfo(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Phương thức thanh toán',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._methods.map(
                    (option) => PaymentMethodCard(
                      option: option,
                      isSelected: _selectedMethod == option.method,
                      onTap: () => setState(() => _selectedMethod = option.method),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: Text(
                  venueName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDeposit ? 'Số tiền cọc (30%)' : 'Thanh toán còn lại',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${paymentAmount.toStringAsFixed(0)}đ',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _onContinue,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.buttonGradientStart, AppColors.buttonGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Tiếp tục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() async {
    if (_selectedMethod == PaymentMethod.cash) {
      final confirmed = await showCashPaymentConfirmDialog();
      if (confirmed) {
        await _processCashPayment();
      }
    } else {
      Get.toNamed(
        AppPages.paymentQR,
        arguments: {
          'bookingId': bookingId,
          'venueName': venueName,
          'totalPrice': totalPrice,
          'paymentAmount': paymentAmount,
          'paymentType': paymentType,
          'paymentMethod': _selectedMethod,
        },
      );
    }
  }

  Future<void> _processCashPayment() async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      barrierDismissible: false,
    );

    try {
      final apiService = Get.find<ApiServiceImpl>();
      if (isDeposit) {
        await apiService.createDepositPayment(
          bookingId,
          paymentMethod: _selectedMethod.value,
        );
      } else {
        await apiService.createFinalPayment(
          bookingId,
          paymentMethod: _selectedMethod.value,
        );
      }

      Get.back();
      Get.back();
      Get.snackbar(
        'Thành công',
        isDeposit
            ? 'Đặt cọc tiền mặt thành công. Vui lòng thanh toán tại sân.'
            : 'Thanh toán tiền mặt thành công.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Lỗi',
        'Không thể xử lý thanh toán. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
