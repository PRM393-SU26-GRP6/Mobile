import 'package:flutter/material.dart';

import 'auth_text_field.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.onTogglePassword,
    required this.emailValidator,
    required this.passwordValidator,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final VoidCallback onTogglePassword;
  final String? Function(String?) emailValidator;
  final String? Function(String?) passwordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Row(
          children: [
            Checkbox(value: true, onChanged: (_) {}),
            const Text('Ghi nhớ đăng nhập'),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Quên mật khẩu?')),
          ],
        ),
      ],
    );
  }
}
