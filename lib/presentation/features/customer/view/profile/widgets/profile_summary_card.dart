import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/domain/models/login_response_model.dart';
import 'package:flutter/material.dart';

class ProfileSummaryCard extends StatelessWidget {
  final UserAuthData? user;

  const ProfileSummaryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person, size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Text(
            user?.fullName ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _roleLabel(user?.roles?.firstOrNull),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String? role) {
    return role?.trim().toLowerCase() == 'owner' ? 'Chủ sân' : 'Khách hàng';
  }
}
