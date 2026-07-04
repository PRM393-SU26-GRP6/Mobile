import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SePayQrCard extends StatelessWidget {
  final SePayQRInfoModel? qrInfo;

  const SePayQrCard({super.key, required this.qrInfo});

  @override
  Widget build(BuildContext context) {
    if (qrInfo == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.primary),
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
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder, width: 1),
            ),
            child: QrImageView(
              data: qrInfo!.qrUrl,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              errorStateBuilder: (cxt, err) => Container(
                alignment: Alignment.center,
                width: 220,
                height: 220,
                child: const Text('Không thể tạo mã QR'),
              ),
            ),
          ),
          if (qrInfo!.bankInfo != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildBankRow('Ngân hàng', qrInfo!.bankInfo!.bankId),
            const SizedBox(height: 6),
            _buildBankRow('Số tài khoản', qrInfo!.bankInfo!.accountNo),
            const SizedBox(height: 6),
            _buildBankRow('Chủ tài khoản', qrInfo!.bankInfo!.accountName),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.info_outline,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: 6),
              Text(
                'Hệ thống tự động xác nhận sau khi nhận được thanh toán',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
