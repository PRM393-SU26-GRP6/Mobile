import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/controller/otp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtpController>();
    controller.applyRouteArguments(Get.arguments);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                _buildAppBar(),
                const SizedBox(height: 48),
                _buildHeader(),
                const SizedBox(height: 48),
                _OtpInput(controller: controller),
                const SizedBox(height: 32),
                _ResendSection(controller: controller),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        tooltip: 'Quay lại',
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 48,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Xác thực OTP',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập mã OTP đã được gửi đến email của bạn',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _OtpInput extends StatefulWidget {
  final OtpController controller;

  const _OtpInput({required this.controller});

  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  final List<TextEditingController> _controllers =
      List.generate(OtpController.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(OtpController.otpLength, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < OtpController.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = _controllers.map((c) => c.text).join();
    widget.controller.otpController.text = otp;
    widget.controller.onOtpChanged(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoading.value) {
        return const SizedBox(
          width: 200,
          height: 60,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(OtpController.otpLength, (index) {
          return Container(
            width: 46,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              onChanged: (value) => _onChanged(value, index),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          );
        }),
      );
    });
  }
}

class _ResendSection extends StatelessWidget {
  final OtpController controller;

  const _ResendSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) return const SizedBox.shrink();

      return Column(
        children: [
          Text(
            'Gửi lại mã sau ${controller.countdown.value}s',
            style:
                const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: controller.canResend.value ? controller.resendOtp : null,
            child: Text(
              'Gửi lại mã OTP',
              style: TextStyle(
                color: controller.canResend.value
                    ? AppColors.accent
                    : AppColors.textSecondary.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      );
    });
  }
}
