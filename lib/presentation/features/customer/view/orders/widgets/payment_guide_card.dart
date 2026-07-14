import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PaymentGuideCard extends StatelessWidget {
  const PaymentGuideCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(Icons.info_outline, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Hướng dẫn thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _GuideStep('1', 'Mở ứng dụng ngân hàng hoặc ví điện tử'),
          _GuideStep(
              '2', 'Quét mã QR hoặc chuyển khoản theo thông tin hiển thị'),
          _GuideStep('3', 'Thanh toán đúng số tiền và nội dung chuyển khoản'),
          _GuideStep(
              '4', 'Hệ thống sẽ tự động xác nhận sau khi nhận thanh toán'),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final String number;
  final String text;

  const _GuideStep(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
