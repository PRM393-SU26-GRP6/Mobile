import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          IconButton.filledTonal(
            tooltip: 'Quay lại',
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Text(
              'Hồ sơ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
