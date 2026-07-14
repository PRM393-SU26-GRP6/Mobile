import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerHomeHeader extends StatelessWidget {
  final AuthController authController;

  const CustomerHomeHeader({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TP. Hồ Chí Minh',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'TÌM SÂN BÓNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Hồ sơ',
            onPressed: () => Get.toNamed(AppPages.userProfile),
            icon: const Icon(Icons.person_outline, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có muốn đăng xuất khỏi tài khoản không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) await authController.logout();
  }
}
