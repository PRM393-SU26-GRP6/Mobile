import 'package:flutter/material.dart';

class RoleSwitch extends StatelessWidget {
  const RoleSwitch({
    required this.role,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final String role;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
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
      selected: {role},
      onSelectionChanged: enabled ? (values) => onChanged(values.first) : null,
    );
  }
}
