import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:exe101/presentation/features/auth/view/widgets/auth_text_field.dart';
import 'package:exe101/presentation/features/auth/view/widgets/password_requirements.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterForm extends StatefulWidget {
  final RegisterController controller;

  const RegisterForm({super.key, required this.controller});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: widget.controller.fullNameController,
          label: 'Họ và tên',
          hint: 'Nhập họ và tên',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.controller.emailController,
          label: 'Email',
          hint: 'Nhập email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: widget.controller.phoneController,
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        Obx(
          () => AuthTextField(
            controller: widget.controller.passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            errorText: widget.controller.passwordError.value,
            onToggleVisibility: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => AuthTextField(
            controller: widget.controller.confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmation,
            errorText: widget.controller.confirmPasswordError.value,
            onToggleVisibility: () {
              setState(() => _obscureConfirmation = !_obscureConfirmation);
            },
          ),
        ),
        const SizedBox(height: 14),
        const PasswordRequirements(),
        const SizedBox(height: 24),
        Obx(
          () => SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: widget.controller.isLoading.value
                  ? null
                  : widget.controller.submitRegister,
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
                      'Đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: Get.back,
          child: const Text('Đã có tài khoản? Đăng nhập'),
        ),
      ],
    );
  }
}
