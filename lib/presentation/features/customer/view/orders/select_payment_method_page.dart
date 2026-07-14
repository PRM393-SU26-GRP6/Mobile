import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/controller/booking_controller.dart';
import 'package:exe101/presentation/features/customer/controller/payment_actions_controller.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/cash_payment_confirm_dialog.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_continue_bar.dart';
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

  String get paymentAmountLabel {
    if (isDeposit) return 'Số tiền cọc';
    return 'Thanh toán còn lại';
  }

  PaymentMethod _selectedMethod = PaymentMethod.sePay;

  final List<PaymentMethodOption> _methods = const [
    PaymentMethodOption(
      method: PaymentMethod.sePay,
      name: 'SePay QR',
      description: 'Quét mã QR để thanh toán',
      icon: Icons.qr_code_2,
      color: Color(0xFF6C63FF),
    ),
    PaymentMethodOption(
      method: PaymentMethod.moMo,
      name: 'MoMo',
      description: 'Chưa hỗ trợ trên BE',
      icon: Icons.account_balance_wallet,
      color: Color(0xFFA50064),
    ),
    PaymentMethodOption(
      method: PaymentMethod.vnPay,
      name: 'VNPay',
      description: 'Chưa hỗ trợ trên BE',
      icon: Icons.payment,
      color: Color(0xFF0066B3),
    ),
    PaymentMethodOption(
      method: PaymentMethod.cash,
      name: 'Tiền mặt',
      description: 'Thanh toán trực tiếp tại sân',
      icon: Icons.payments,
      color: Color(0xFF16A34A),
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
          Expanded(child: _buildMethods()),
          PaymentContinueBar(onPressed: _onContinue),
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
          _priceRow('Sân', venueName),
          const SizedBox(height: 8),
          _priceRow('Tổng tiền', '${totalPrice.toStringAsFixed(0)}d',
              strikeValue: true),
          const SizedBox(height: 4),
          _priceRow(
            paymentAmountLabel,
            '${paymentAmount.toStringAsFixed(0)}d',
            highlightValue: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool strikeValue = false,
    bool highlightValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: highlightValue ? 16 : 14,
            color: highlightValue ? Colors.white : Colors.white70,
            fontWeight: highlightValue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: highlightValue ? 20 : 14,
              color: highlightValue ? Colors.white : Colors.white70,
              fontWeight: highlightValue ? FontWeight.bold : FontWeight.w600,
              decoration: strikeValue ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethods() {
    return Container(
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
    );
  }

  Future<void> _onContinue() async {
    if (_selectedMethod == PaymentMethod.cash) {
      final confirmed = await showCashPaymentConfirmDialog();
      if (confirmed) await _processCashPayment();
      return;
    }

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

  Future<void> _processCashPayment() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      final paymentController = Get.find<PaymentActionsController>();
      if (isDeposit) {
        await paymentController.createDeposit(
          bookingId,
          paymentMethod: _selectedMethod.value,
        );
      } else {
        await paymentController.createFinal(
          bookingId,
          paymentMethod: _selectedMethod.value,
        );
      }

      Get.back();
      _returnToOrders();
      Get.snackbar(
        'Thành công',
        'Đã tạo thanh toán thành công.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (_) {
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

  void _returnToOrders() {
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().refreshBookings();
    }
    Get.until((route) => route.settings.name == AppPages.customerHome);
  }
}
