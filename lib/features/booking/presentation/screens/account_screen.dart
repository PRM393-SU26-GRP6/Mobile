import 'package:flutter/material.dart';

import '../../../../core/settings/app_settings.dart';
import '../../data/auth_api_client.dart';
import '../../data/auth_models.dart';
import '../widgets/booking_ui.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    required this.settings,
    required this.onLogout,
    this.user,
    this.accessToken,
    super.key,
  });

  final AppSettings settings;
  final AuthUser? user;
  final String? accessToken;
  final VoidCallback onLogout;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _authClient = AuthApiClient();
  bool _isLoggingOut = false;

  @override
  void dispose() {
    _authClient.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final accessToken = widget.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      widget.onLogout();
      return;
    }

    setState(() => _isLoggingOut = true);
    try {
      final response = await _authClient.logout(accessToken: accessToken);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message.isNotEmpty
                ? response.message
                : 'Đăng xuất thành công',
          ),
        ),
      );
      widget.onLogout();
    } on AuthApiException catch (error) {
      _showError(error.message);
    } on Object catch (error) {
      _showError('Không kết nối được API đăng xuất: $error');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final displayName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName
        : user?.email ?? 'Tài khoản';
    final accountDetail = user?.phoneNumber.trim().isNotEmpty == true
        ? user!.phoneNumber
        : user?.email ?? 'Thông tin tài khoản';

    return BookingShell(
      key: const ValueKey('account'),
      child: AnimatedBuilder(
        animation: widget.settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 54, 18, 24),
            children: [
              const Row(
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
                          'Tài khoản và cài đặt',
                          style: TextStyle(color: bookingMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              BookingCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: bookingPrimary,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(accountDetail),
                ),
              ),
              const SizedBox(height: 12),
              BookingCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BookingSectionTitle(title: 'Cài đặt ứng dụng'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Chế độ tối'),
                      value: widget.settings.isDarkMode,
                      onChanged: widget.settings.updateTheme,
                    ),
                    DropdownButtonFormField<Locale>(
                      initialValue: widget.settings.locale,
                      decoration: const InputDecoration(labelText: 'Ngôn ngữ'),
                      items: const [
                        DropdownMenuItem(
                          value: Locale('vi'),
                          child: Text('Tiếng Việt'),
                        ),
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                      ],
                      onChanged: (locale) {
                        if (locale != null) {
                          widget.settings.updateLocale(locale);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoggingOut ? null : _logout,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: Colors.red.shade700,
                  side: BorderSide(color: Colors.red.shade200),
                ),
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      ),
    );
  }
}
