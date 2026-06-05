import 'package:flutter/material.dart';

import '../booking_ui.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.isRegisterMode,
    required this.isSubmitting,
    required this.onPressed,
    super.key,
  });

  final bool isRegisterMode;
  final bool isSubmitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: bookingPrimary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: isSubmitting
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isRegisterMode ? 'Đăng ký' : 'Đăng nhập'),
                const SizedBox(width: 8),
                Icon(
                  isRegisterMode ? Icons.person_add_alt_1 : Icons.arrow_forward,
                  size: 18,
                ),
              ],
            ),
    );
  }
}
