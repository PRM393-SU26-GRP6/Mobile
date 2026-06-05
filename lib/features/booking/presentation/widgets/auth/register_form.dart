import 'package:flutter/material.dart';

import 'auth_text_field.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.fullNameValidator,
    required this.emailValidator,
    required this.phoneValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
    super.key,
  });

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final String? Function(String?) fullNameValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) passwordValidator;
  final String? Function(String?) confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          controller: fullNameController,
          label: 'Họ và tên',
          icon: Icons.badge_outlined,
          hint: 'Nguyễn Văn A',
          validator: fullNameValidator,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          hint: 'ban@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: emailValidator,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone_outlined,
          hint: '0901234567',
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline,
          hint: '••••••••',
          obscureText: hidePassword,
          validator: passwordValidator,
          suffix: IconButton(
            onPressed: onTogglePassword,
            icon: Icon(
              hidePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: confirmPasswordController,
          label: 'Nhập lại mật khẩu',
          icon: Icons.lock_reset_outlined,
          hint: '••••••••',
          obscureText: hideConfirmPassword,
          validator: confirmPasswordValidator,
          suffix: IconButton(
            onPressed: onToggleConfirmPassword,
            icon: Icon(
              hideConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ],
    );
  }
}
