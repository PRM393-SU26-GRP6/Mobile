import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:exe101/presentation/features/customer/shared/customer_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodBanner extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isDeposit;

  const PaymentMethodBanner({
    super.key,
    required this.paymentMethod,
    required this.isDeposit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            getPaymentMethodIcon(paymentMethod),
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
                      ? 'Thanh toán cọc - ${getPaymentMethodText(paymentMethod)}'
                      : 'Thanh toán - ${getPaymentMethodText(paymentMethod)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  getPaymentMethodDescription(paymentMethod),
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
}
