import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';

class ProfileAccountSection extends StatelessWidget {
  final UserProfileController controller;

  const ProfileAccountSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin tài khoản',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileField(
            icon: Icons.person_outline,
            label: 'Họ và tên',
            controller: controller.nameController,
          ),
          const Divider(height: 24),
          _ProfileField(
            icon: Icons.email_outlined,
            label: 'Email',
            value: controller.user.value?.email ?? '',
            readOnly: true,
          ),
          const Divider(height: 24),
          _ProfileField(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController? controller;
  final String? value;
  final bool readOnly;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.icon,
    required this.label,
    this.controller,
    this.value,
    this.readOnly = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: readOnly
              ? _ReadOnlyValue(label: label, value: value ?? '')
              : TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    labelText: label,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value.isEmpty ? 'Chưa cập nhật' : value),
      ],
    );
  }
}
