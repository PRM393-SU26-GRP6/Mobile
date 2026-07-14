import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/constant/app_strings.dart';
import 'package:exe101/core/theme/app_dimensions.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/view/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.accent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 28),
              const _BrandHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppContentWidth.form,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppStrings.auth.login,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppStrings.auth.loginWelcome,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          LoginForm(controller: controller),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () =>
                                Get.toNamed(AppPages.roleSelection),
                            child: Text(AppStrings.auth.noAccount),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 44,
          backgroundColor: Colors.white24,
          child: Icon(Icons.sports_soccer, size: 48, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'PITCHBOOK',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.auth.quickBooking,
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }
}
