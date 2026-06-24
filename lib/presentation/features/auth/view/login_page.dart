import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/auth/binding/auth_binding.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/auth/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      AuthBinding().dependencies();
    }
    final authController = Get.find<AuthController>();
    final registerController = Get.find<RegisterController>();

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
              _buildLogo(),
              const SizedBox(height: 12),
              const Text('PITCHBOOK',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Đặt sân bóng nhanh chóng',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
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
                          Row(children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isLogin = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isLogin
                                        ? const Color(0xFF0FA24A)
                                        : const Color(0xFFEFF8EF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: isLogin
                                            ? const Color(0xFF0FA24A)
                                            : const Color(0xFFDFF1E0)),
                                  ),
                                  child: Center(
                                      child: Text('Đăng nhập',
                                          style: TextStyle(
                                              color: isLogin
                                                  ? Colors.white
                                                  : Colors.green[800],
                                              fontWeight: FontWeight.w700))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => isLogin = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isLogin
                                        ? const Color(0xFF0FA24A)
                                        : const Color(0xFFEFF8EF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: !isLogin
                                            ? const Color(0xFF0FA24A)
                                            : const Color(0xFFDFF1E0)),
                                  ),
                                  child: Center(
                                      child: Text('Đăng ký',
                                          style: TextStyle(
                                              color: !isLogin
                                                  ? Colors.white
                                                  : Colors.green[800],
                                              fontWeight: FontWeight.w700))),
                                ),
                              ),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          const Text('VAI TRÒ',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Expanded(
                                child: Obx(() => GestureDetector(
                                      onTap: () => registerController
                                          .setRole('Customer'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: registerController
                                                      .selectedRole.value ==
                                                  'Customer'
                                              ? const Color(0xFFF3FBF4)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: registerController
                                                          .selectedRole.value ==
                                                      'Customer'
                                                  ? const Color(0xFF0FA24A)
                                                  : const Color(0xFFDFF1E0)),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.person_outline,
                                                  color: Color(0xFF0FA24A)),
                                              SizedBox(width: 8),
                                              Text('Khách hàng',
                                                  style: TextStyle(
                                                      color: Color(0xFF0FA24A)))
                                            ]),
                                      ),
                                    ))),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Obx(() => GestureDetector(
                                      onTap: () =>
                                          registerController.setRole('Owner'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: registerController
                                                      .selectedRole.value ==
                                                  'Owner'
                                              ? const Color(0xFFF3FBF4)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: registerController
                                                          .selectedRole.value ==
                                                      'Owner'
                                                  ? const Color(0xFF0FA24A)
                                                  : const Color(0xFFDFF1E0)),
                                        ),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.business_outlined,
                                                  color: Color(0xFF9AA8A0)),
                                              SizedBox(width: 8),
                                              Text('Chủ sân',
                                                  style: TextStyle(
                                                      color: Color(0xFF9AA8A0)))
                                            ]),
                                      ),
                                    ))),
                          ]),
                          const SizedBox(height: 20),
                          isLogin
                              ? _LoginForm(controller: authController)
                              : _RegisterForm(controller: registerController),
                          const SizedBox(height: 16),
                          Center(child: _buildRegisterPrompt()),
                          const SizedBox(height: 32),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
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
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Chưa có tài khoản? ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => setState(() => isLogin = false),
          child: const Text(
            'Đăng ký ngay',
            style: TextStyle(
              color: Color(0xFF0FA24A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  final AuthController controller;

  const _LoginForm({required this.controller});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _tenDangNhapFocus = FocusNode();
  final _matKhauFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tenDangNhapFocus.dispose();
    _matKhauFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          focusNode: _tenDangNhapFocus,
          nextFocus: _matKhauFocus,
          controller: widget.controller.emailController,
          label: 'Tên đăng nhập',
          hintText: 'Nhập tên đăng nhập',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          focusNode: _matKhauFocus,
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
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.controller.login(),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Quên mật khẩu?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => _buildLoginButton()),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: widget.controller.isLoading.value ? null : widget.controller.login,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF0FA24A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.18),
              blurRadius: 12,
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
                  'Đăng nhập',
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        TextField(
          focusNode: focusNode,
          controller: controller,
          obscureText: obscureText,
          textInputAction: textInputAction,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: Icon(prefixIcon, color: Colors.black38, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF3FBF4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDFF1E0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDFF1E0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF0FA24A), width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _regTextField(
            controller: widget.controller.fullNameController,
            label: 'Họ và tên',
            hintText: 'Nhập họ và tên',
            prefixIcon: Icons.person_outline),
        const SizedBox(height: 16),
        _regTextField(
            controller: widget.controller.emailController,
            label: 'Email',
            hintText: 'your@email.com',
            prefixIcon: Icons.email_outlined),
        const SizedBox(height: 16),
        _regTextField(
            controller: widget.controller.phoneController,
            label: 'Số điện thoại',
            hintText: '09xxxxxxxx',
            prefixIcon: Icons.phone),
        const SizedBox(height: 16),
        _regTextField(
            controller: widget.controller.passwordController,
            label: 'Mật khẩu',
            hintText: 'Nhập mật khẩu',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black38,
                    size: 20),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword))),
        const SizedBox(height: 16),
        _regTextField(
            controller: widget.controller.confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword),
        const SizedBox(height: 20),
        Obx(() => _buildRegisterButton()),
      ],
    );
  }

  Widget _regTextField(
      {required TextEditingController controller,
      required String label,
      required String hintText,
      required IconData prefixIcon,
      bool obscureText = false,
      Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: Icon(prefixIcon, color: Colors.black38, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF3FBF4),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDFF1E0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFDFF1E0))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF0FA24A), width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: widget.controller.isLoading.value
          ? null
          : widget.controller.submitRegister,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
            color: const Color(0xFF0FA24A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.green.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 6))
            ]),
        child: Center(
          child: widget.controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const Text('Đăng ký',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
        ),
      ),
    );
  }
}
