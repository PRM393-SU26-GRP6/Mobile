import 'package:flutter/material.dart';

import '../booking_ui.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({required this.onToggleList, super.key});

  final VoidCallback onToggleList;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: bookingMuted),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm khu vực hoặc tên sân',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggleList,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
    );
  }
}
