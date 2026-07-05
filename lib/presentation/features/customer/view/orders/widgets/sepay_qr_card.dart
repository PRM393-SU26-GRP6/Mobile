import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SePayQrCard extends StatelessWidget {
  final SePayQRInfoModel? qrInfo;

  const SePayQrCard({super.key, required this.qrInfo});

  bool get _hasNetworkQrImage {
    final uri = Uri.tryParse(qrInfo?.qrUrl ?? '');
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

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
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(_hasNetworkQrImage ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.16)),
            ),
            child: SizedBox(
              width: _hasNetworkQrImage ? double.infinity : 270,
              height: _hasNetworkQrImage ? 370 : 270,
              child: _hasNetworkQrImage
                  ? Image.network(
                      qrInfo!.qrUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Không thể tải mã QR')),
                    )
                  : QrImageView(
                      data: qrInfo!.qrUrl,
                      version: QrVersions.auto,
                      size: 270,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (cxt, err) =>
                          const Center(child: Text('Không thể tạo mã QR')),
                    ),
            ),
          ),
          if (!_hasNetworkQrImage && qrInfo!.bankInfo != null) ...[
            const SizedBox(height: 18),
            const Divider(height: 1, color: AppColors.inputBorder),
            const SizedBox(height: 14),
            _buildBankRow(Icons.account_balance, 'Ngân hàng',
                qrInfo!.bankInfo!.bankId.toUpperCase()),
            const SizedBox(height: 10),
            _buildBankRow(
              Icons.credit_card,
              'Số tài khoản',
              qrInfo!.bankInfo!.accountNo,
            ),
            const SizedBox(height: 10),
            _buildBankRow(
              Icons.person_outline,
              'Chủ tài khoản',
              qrInfo!.bankInfo!.accountName,
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hệ thống tự động xác nhận sau khi nhận được thanh toán',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
