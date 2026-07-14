import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/view/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginForm extends StatefulWidget {
  final AuthController controller;

  const LoginForm({super.key, required this.controller});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: widget.controller.emailController,
          label: 'Email',
          hint: 'Nhập email của bạn',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: widget.controller.passwordController,
          label: 'Mật khẩu',
          hint: 'Nhập mật khẩu',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          onToggleVisibility: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        const SizedBox(height: 24),
        Obx(
          () => SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: widget.controller.isLoading.value
                  ? null
                  : widget.controller.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: widget.controller.isLoading.value
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
