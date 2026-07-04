import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/data/remote/api_service.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectPaymentMethodPage extends StatefulWidget {
  const SelectPaymentMethodPage({super.key});

  @override
  State<SelectPaymentMethodPage> createState() => _SelectPaymentMethodPageState();
}

class _SelectPaymentMethodPageState extends State<SelectPaymentMethodPage> {
  final String bookingId = Get.arguments['bookingId'] ?? '';
  final String venueName = Get.arguments['venueName'] ?? 'Sân bóng';
  final double totalPrice = Get.arguments['totalPrice'] ?? 0;
  final double paymentAmount = Get.arguments['paymentAmount'] ?? 0.0;
  final String paymentType = Get.arguments['paymentType'] ?? 'deposit';

  bool get isDeposit => paymentType == 'deposit';
  bool get isFinal => paymentType == 'final';

  PaymentMethod _selectedMethod = PaymentMethod.sePay;

  final List<_PaymentMethodOption> _methods = [
    _PaymentMethodOption(
      method: PaymentMethod.sePay,
      name: 'SePay QR',
      description: 'Quét mã QR để thanh toán',
      icon: Icons.qr_code_2,
      color: const Color(0xFF6C63FF),
    ),
    _PaymentMethodOption(
      method: PaymentMethod.moMo,
      name: 'MoMo',
      description: 'Thanh toán qua ví MoMo',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFFA50064),
    ),
    _PaymentMethodOption(
      method: PaymentMethod.vnPay,
      name: 'VNPay',
      description: 'Thanh toán qua VNPay',
      icon: Icons.payment,
      color: const Color(0xFF0066B3),
    ),
    _PaymentMethodOption(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._methods.map((option) => _buildMethodCard(option)),
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

  Widget _buildMethodCard(_PaymentMethodOption option) {
    final isSelected = _selectedMethod == option.method;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = option.method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withValues(alpha: 0.1)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? option.color : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: option.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? option.color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? option.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? option.color : AppColors.textSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
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

  void _onContinue() {
    if (_selectedMethod == PaymentMethod.cash) {
      Get.dialog(
        AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Thanh toán tiền mặt'),
            ],
          ),
          content: const Text(
            'Bạn sẽ thanh toán tiền mặt trực tiếp tại sân. Vui lòng đến đúng giờ và mang theo số tiền đúng với số tiền cọc.\n\nBạn có xác nhận đặt sân không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _processCashPayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
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

class _PaymentMethodOption {
  final PaymentMethod method;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  _PaymentMethodOption({
    required this.method,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
