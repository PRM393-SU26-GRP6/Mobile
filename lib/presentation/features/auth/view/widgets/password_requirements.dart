import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mật khẩu cần có:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'Ít nhất 8 ký tự, một chữ in hoa, một chữ số và một ký tự đặc biệt.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
