import 'package:flutter/material.dart';

import '../../data/auth_api_client.dart';
import '../../data/auth_models.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Đăng nhập thành công',
          ),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Đăng ký thành công',
          ),
        ),
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  void _submit() {
    if (_isSubmitting) return;
    if (_isRegisterMode) {
      _register();
    } else {
      _login();
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
            const _BrandHeader(),
            const SizedBox(height: 28),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Đăng nhập'),
                  icon: Icon(Icons.login_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Đăng ký'),
                  icon: Icon(Icons.person_add_alt_1_outlined),
                ),
              ],
              selected: {_isRegisterMode},
              onSelectionChanged: _isSubmitting
                  ? null
                  : (values) {
                      setState(() {
                        _isRegisterMode = values.first;
                        _formKey.currentState?.reset();
                      });
                    },
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
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'Người chơi',
                  label: Text('Người chơi'),
                  icon: Icon(Icons.sports_soccer),
                ),
                ButtonSegment(
                  value: 'Chủ sân',
                  label: Text('Chủ sân'),
                  icon: Icon(Icons.storefront_outlined),
                ),
              ],
              selected: {_role},
              onSelectionChanged: _isSubmitting
                  ? null
                  : (values) => setState(() => _role = values.first),
            ),
            const SizedBox(height: 16),
            if (_isRegisterMode) ...[
              _AuthTextField(
                controller: _fullNameController,
                label: 'Họ và tên',
                icon: Icons.badge_outlined,
                hint: 'Nguyễn Văn A',
                validator: (value) => _required(value, 'Vui lòng nhập họ tên'),
              ),
              const SizedBox(height: 12),
            ],
            _AuthTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'ban@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 12),
            if (_isRegisterMode) ...[
              _AuthTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                icon: Icons.phone_outlined,
                hint: '0901234567',
                keyboardType: TextInputType.phone,
                validator: _phoneValidator,
              ),
              const SizedBox(height: 12),
            ],
            _AuthTextField(
              controller: _passwordController,
              label: 'Mật khẩu',
              icon: Icons.lock_outline,
              hint: '••••••••',
              obscureText: _hidePassword,
              validator: _isRegisterMode
                  ? _passwordValidator
                  : _loginPasswordValidator,
              suffix: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: Icon(
                  _hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            if (_isRegisterMode) ...[
              const SizedBox(height: 12),
              _AuthTextField(
                controller: _confirmPasswordController,
                label: 'Nhập lại mật khẩu',
                icon: Icons.lock_reset_outlined,
                hint: '••••••••',
                obscureText: _hideConfirmPassword,
                validator: _confirmPasswordValidator,
                suffix: IconButton(
                  onPressed: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword,
                  ),
                  icon: Icon(
                    _hideConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ],
            if (!_isRegisterMode) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(value: true, onChanged: (_) {}),
                  const Text('Ghi nhớ đăng nhập'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Quên mật khẩu?'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: bookingPrimary,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isRegisterMode ? 'Đăng ký' : 'Đăng nhập'),
                        const SizedBox(width: 8),
                        Icon(
                          _isRegisterMode
                              ? Icons.person_add_alt_1
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
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

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: bookingPrimary,
          foregroundColor: Colors.white,
          child: Text('⚽', style: TextStyle(fontSize: 26)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PitchBook',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: bookingText,
                ),
              ),
              Text(
                'Đặt sân bóng nhanh trong vài chạm',
                style: TextStyle(color: bookingMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: bookingLine),
        ),
      ),
    );
  }
}
