import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/shared/customer_constants.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_guide_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_info_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_method_banner.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_qr_status_button.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/payment_redirect_card.dart';
import 'package:exe101/presentation/features/customer/view/orders/widgets/sepay_qr_card.dart';
import 'package:flutter/material.dart';

class PaymentQrContent extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isDeposit;
  final bool isSePay;
  final String venueName;
  final double paymentAmount;
  final PaymentModel? payment;
  final SePayQRInfoModel? sePayQRInfo;
  final VoidCallback onCheckStatus;

  const PaymentQrContent({
    super.key,
    required this.paymentMethod,
    required this.isDeposit,
    required this.isSePay,
    required this.venueName,
    required this.paymentAmount,
    required this.payment,
    required this.sePayQRInfo,
    required this.onCheckStatus,
  });

  @override
  Widget build(BuildContext context) {
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
            payment: payment,
          ),
          const SizedBox(height: 16),
          if (isSePay) SePayQrCard(qrInfo: sePayQRInfo),
          if (!isSePay)
            PaymentRedirectCard(
              payment: payment,
              paymentMethodText: getPaymentMethodText(paymentMethod),
              description: getPaymentMethodDescription(paymentMethod),
            ),
          const SizedBox(height: 16),
          if (isSePay) const PaymentGuideCard(),
          const SizedBox(height: 24),
          PaymentQrStatusButton(onPressed: onCheckStatus),
        ],
      ),
    );
  }
}
