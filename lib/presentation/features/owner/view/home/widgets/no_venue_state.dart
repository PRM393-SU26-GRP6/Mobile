import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NoVenueState extends StatelessWidget {
  const NoVenueState({super.key, required this.onCreateVenue});

  final VoidCallback onCreateVenue;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stadium_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có cụm sân',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo cụm sân đầu tiên để bắt đầu quản lý',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateVenue,
              icon: const Icon(Icons.add),
              label: const Text('Tạo cụm sân'),
            ),
          ],
        ),
      ),
    );
  }
}
