import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/binding/auth_binding.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<RegisterController>()) {
      AuthBinding().dependencies();
    }
    final controller = Get.find<RegisterController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0FA24A), Color(0xFF0A7A36)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12), width: 2),
                  ),
                  child: const Center(
                      child: Icon(Icons.sports_soccer,
                          size: 52, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('PITCHBOOK',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24))),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAppBar(controller),
                        const SizedBox(height: 8),
                        _buildHeader(controller),
                        const SizedBox(height: 20),
                        _RegisterForm(controller: controller),
                        const SizedBox(height: 16),
                        _buildLoginPrompt(),
                        const SizedBox(height: 32),
                      ],
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

  Widget _buildAppBar(RegisterController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          const Spacer(),
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: controller.selectedRole.value == 'Owner'
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.selectedRole.value == 'Owner'
                          ? Icons.business_outlined
                          : Icons.person_outline,
                      size: 16,
                      color: controller.selectedRole.value == 'Owner'
                          ? Colors.orange
                          : Colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      controller.selectedRole.value == 'Owner'
                          ? 'Chủ sân'
                          : 'Khách hàng',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: controller.selectedRole.value == 'Owner'
                            ? Colors.orange
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildHeader(RegisterController controller) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.sports_soccer, size: 52, color: AppColors.accent),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tạo tài khoản',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Đăng ký để bắt đầu',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Đã có tài khoản? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: const Text(
            'Đăng nhập ngay',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterForm extends StatefulWidget {
  final RegisterController controller;

  const _RegisterForm({required this.controller});

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _focusNodes = List.generate(5, (_) => FocusNode());
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          focusNode: _focusNodes[0],
          nextFocus: _focusNodes[1],
          controller: widget.controller.fullNameController,
          label: 'Họ và tên',
          hintText: 'Nhập họ và tên',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          focusNode: _focusNodes[1],
          nextFocus: _focusNodes[2],
          controller: widget.controller.emailController,
          label: 'Email',
          hintText: 'Nhập email của bạn',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          focusNode: _focusNodes[2],
          nextFocus: _focusNodes[3],
          controller: widget.controller.phoneController,
          label: 'Số điện thoại',
          hintText: 'Nhập số điện thoại',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final error = widget.controller.passwordError.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                focusNode: _focusNodes[3],
                nextFocus: _focusNodes[4],
                controller: widget.controller.passwordController,
                label: 'Mật khẩu',
                hintText: 'Nhập mật khẩu',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (value) => widget.controller.validatePassword(value),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  error,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 8),
              _buildPasswordRequirement(),
            ],
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final error = widget.controller.confirmPasswordError.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                focusNode: _focusNodes[4],
                controller: widget.controller.confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                hintText: 'Nhập lại mật khẩu',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.controller.submitRegister(),
                onChanged: (value) => widget.controller.validateConfirmPassword(
                  value,
                  widget.controller.passwordController.text,
                ),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  error,
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
              ],
            ],
          );
        }),
        const SizedBox(height: 28),
        Obx(() => _buildSubmitButton()),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: widget.controller.isLoading.value
          ? null
          : widget.controller.submitRegister,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.buttonGradientStart,
              AppColors.buttonGradientEnd
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: widget.controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Đăng ký',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required FocusNode focusNode,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction textInputAction = TextInputAction.next,
    Function(String)? onSubmitted,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 14),
            prefixIcon:
                Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
            suffixIcon: suffixIcon,
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
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mật khẩu phải có:',
          style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 6),
        _buildRequirementRow(Icons.text_fields, 'Ít nhất 8 ký tự'),
        _buildRequirementRow(Icons.arrow_upward, 'Ít nhất 1 chữ in hoa (A-Z)'),
        _buildRequirementRow(Icons.pin, 'Ít nhất 1 chữ số (0-9)'),
        _buildRequirementRow(
            Icons.star_border, 'Ít nhất 1 ký tự đặc biệt (!@#\$%...)'),
      ],
    );
  }

  Widget _buildRequirementRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon,
              size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
