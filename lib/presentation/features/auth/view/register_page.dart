import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:exe101/presentation/features/auth/view/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _RegisterHeader(controller: controller),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: RegisterForm(controller: controller),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  final RegisterController controller;

  const _RegisterHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 22),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Quay lại',
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Spacer(),
              Obx(
                () => Chip(
                  avatar: Icon(
                    controller.selectedRole.value == 'Owner'
                        ? Icons.business_outlined
                        : Icons.person_outline,
                    size: 18,
                  ),
                  label: Text(
                    controller.selectedRole.value == 'Owner'
                        ? 'Chủ sân'
                        : 'Khách hàng',
                  ),
                ),
              ),
            ],
          ),
          const Icon(Icons.sports_soccer, size: 54, color: Colors.white),
          const SizedBox(height: 8),
          const Text(
            'Tạo tài khoản',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Đăng ký để bắt đầu sử dụng PitchBook',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
