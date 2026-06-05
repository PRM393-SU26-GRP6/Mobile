import 'package:flutter/material.dart';

import '../../data/auth_api_client.dart';
import '../../data/auth_models.dart';
import '../widgets/auth/auth_brand_header.dart';
import '../widgets/auth/auth_mode_switch.dart';
import '../widgets/auth/auth_submit_button.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/register_form.dart';
import '../widgets/auth/role_switch.dart';
import '../widgets/booking_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLogin, this.onAuthenticated, super.key});

  final VoidCallback onLogin;
  final ValueChanged<AuthResponse>? onAuthenticated;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authClient = AuthApiClient();
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;
  String _role = 'Người chơi';

  @override
  void dispose() {
    _authClient.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await _authClient.login(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;
      _showMessage(
        response.message.isNotEmpty ? response.message : 'Đăng nhập thành công',
      );
      widget.onAuthenticated?.call(response);
      widget.onLogin();
    } on AuthApiException catch (error) {
      _showError(error.message);
    } on Object catch (error) {
      _showError('Không kết nối được API đăng nhập: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final response = await _authClient.register(
        RegisterRequest(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _normalizedPhoneNumber(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );

      if (!mounted) return;
      _showMessage(
        response.message.isNotEmpty ? response.message : 'Đăng ký thành công',
      );
      widget.onAuthenticated?.call(response);
      widget.onLogin();
    } on AuthApiException catch (error) {
      _showError(error.message);
    } on Object catch (error) {
      _showError('Không kết nối được API đăng ký: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegisterMode ? 'Tạo tài khoản' : 'Chào mừng trở lại';
    final subtitle = _isRegisterMode
        ? 'Đăng ký tài khoản để tìm sân, giữ slot và theo dõi lịch đặt.'
        : 'Đăng nhập để tìm sân, giữ slot và trò chuyện với chủ sân.';

    return BookingShell(
      key: const ValueKey('login'),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 58, 22, 24),
          children: [
            const AuthBrandHeader(),
            const SizedBox(height: 28),
            AuthModeSwitch(
              isRegisterMode: _isRegisterMode,
              enabled: !_isSubmitting,
              onChanged: _setRegisterMode,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: bookingMuted)),
            const SizedBox(height: 24),
            RoleSwitch(
              role: _role,
              enabled: !_isSubmitting,
              onChanged: (role) => setState(() => _role = role),
            ),
            const SizedBox(height: 16),
            if (_isRegisterMode)
              RegisterForm(
                fullNameController: _fullNameController,
                emailController: _emailController,
                phoneController: _phoneController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                hidePassword: _hidePassword,
                hideConfirmPassword: _hideConfirmPassword,
                onTogglePassword: _togglePassword,
                onToggleConfirmPassword: _toggleConfirmPassword,
                fullNameValidator: (value) =>
                    _required(value, 'Vui lòng nhập họ tên'),
                emailValidator: _emailValidator,
                phoneValidator: _phoneValidator,
                passwordValidator: _passwordValidator,
                confirmPasswordValidator: _confirmPasswordValidator,
              )
            else
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
                hidePassword: _hidePassword,
                onTogglePassword: _togglePassword,
                emailValidator: _emailValidator,
                passwordValidator: _loginPasswordValidator,
              ),
            const SizedBox(height: 18),
            AuthSubmitButton(
              isRegisterMode: _isRegisterMode,
              isSubmitting: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _setRegisterMode(bool value) {
    setState(() {
      _isRegisterMode = value;
      _formKey.currentState?.reset();
    });
  }

  void _togglePassword() {
    setState(() => _hidePassword = !_hidePassword);
  }

  void _toggleConfirmPassword() {
    setState(() => _hideConfirmPassword = !_hideConfirmPassword);
  }

  void _submit() {
    if (_isSubmitting) return;
    if (_isRegisterMode) {
      _register();
    } else {
      _login();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  String? _required(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? _emailValidator(String? value) {
    final requiredMessage = _required(value, 'Vui lòng nhập email');
    if (requiredMessage != null) return requiredMessage;
    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final requiredMessage = _required(value, 'Vui lòng nhập số điện thoại');
    if (requiredMessage != null) return requiredMessage;
    final phone = value!.trim().replaceAll(RegExp(r'[\s.-]'), '');
    final isVietnameseLocal = RegExp(r'^0\d{9}$').hasMatch(phone);
    final isInternational = RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone);
    if (!isVietnameseLocal && !isInternational) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? _loginPasswordValidator(String? value) {
    return _required(value, 'Vui lòng nhập mật khẩu');
  }

  String _normalizedPhoneNumber() {
    final phone = _phoneController.text.trim().replaceAll(
      RegExp(r'[\s.-]'),
      '',
    );
    if (RegExp(r'^0\d{9}$').hasMatch(phone)) {
      return '+84${phone.substring(1)}';
    }
    return phone;
  }

  String? _passwordValidator(String? value) {
    final requiredMessage = _required(value, 'Vui lòng nhập mật khẩu');
    if (requiredMessage != null) return requiredMessage;
    if (value!.length < 8) {
      return 'Mật khẩu tối thiểu 8 ký tự';
    }
    if (!RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
    ).hasMatch(value)) {
      return 'Cần chữ hoa, chữ thường, số và ký tự đặc biệt';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredMessage = _required(value, 'Vui lòng nhập lại mật khẩu');
    if (requiredMessage != null) return requiredMessage;
    if (value != _passwordController.text) {
      return 'Mật khẩu nhập lại không khớp';
    }
    return null;
  }
}
