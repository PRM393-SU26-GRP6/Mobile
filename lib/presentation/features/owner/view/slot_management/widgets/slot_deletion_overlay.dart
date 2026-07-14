import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SlotDeletionOverlay extends StatelessWidget {
  const SlotDeletionOverlay({required this.slotCount, super.key});

  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final message = slotCount > 1
        ? 'Đang xóa $slotCount khung giờ...'
        : 'Đang xóa khung giờ...';

    return Positioned.fill(
      child: Stack(
        children: [
          const ModalBarrier(
            key: Key('slot-deletion-barrier'),
            dismissible: false,
            color: Color(0x47000000),
          ),
          Center(
            child: Card(
              elevation: 8,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
