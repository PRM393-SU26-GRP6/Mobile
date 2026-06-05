import 'package:flutter/material.dart';

class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    required this.isRegisterMode,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final bool isRegisterMode;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
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
      selected: {isRegisterMode},
      onSelectionChanged: enabled ? (values) => onChanged(values.first) : null,
    );
  }
}
