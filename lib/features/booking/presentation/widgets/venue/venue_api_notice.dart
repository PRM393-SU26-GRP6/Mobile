import 'package:flutter/material.dart';

class VenueApiNotice extends StatelessWidget {
  const VenueApiNotice({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6D39A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF8A6D1F), size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Đang dùng dữ liệu mẫu vì chưa kết nối được API.',
              style: TextStyle(
                color: Color(0xFF6F5511),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
