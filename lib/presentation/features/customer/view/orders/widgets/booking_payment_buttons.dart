import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BookingPaymentButtons extends StatelessWidget {
  final bool showDeposit;
  final bool showRemaining;
  final VoidCallback onDepositTap;
  final VoidCallback onRemainingTap;

  const BookingPaymentButtons({
    super.key,
    required this.showDeposit,
    required this.showRemaining,
    required this.onDepositTap,
    required this.onRemainingTap,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    if (showDeposit) {
      buttons.add(
        Expanded(
          child: _PaymentActionButton(
            label: 'Thanh toán cọc',
            icon: Icons.qr_code_2,
            onTap: onDepositTap,
            backgroundColor: const Color(0xFF0D6EFD),
          ),
        ),
      );
    }

    if (showRemaining) {
      _addGap(buttons);
      buttons.add(
        Expanded(
          child: _PaymentActionButton(
            label: 'Thanh toán phần còn lại',
            icon: Icons.payments_outlined,
            onTap: onRemainingTap,
            backgroundColor: AppColors.primary,
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Row(children: buttons);
  }

  void _addGap(List<Widget> buttons) {
    if (buttons.isNotEmpty) {
      buttons.add(const SizedBox(width: 8));
    }
  }
}

class _PaymentActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _PaymentActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
