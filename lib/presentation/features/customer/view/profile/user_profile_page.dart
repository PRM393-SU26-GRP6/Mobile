import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController(
      userRepository: Get.find(),
    ));

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, controller),
              ),
              SliverToBoxAdapter(
                child: _buildProfileCard(context, controller),
              ),
              SliverToBoxAdapter(
                child: _buildAccountSection(context, controller),
              ),
              SliverToBoxAdapter(
                child: _buildActionsSection(context, controller),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEAEAEA),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Hồ sơ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.02,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, UserProfileController controller) {
    final user = controller.user.value;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildAvatarSection(),
          const SizedBox(height: 20),
          Text(
            user?.fullName ?? 'Người dùng',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.roles?.firstOrNull ?? 'Customer',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 2,
        ),
      ),
      child: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(46)),
        child: Center(
          child: Icon(
            Icons.person,
            size: 48,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(
      BuildContext context, UserProfileController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Thông tin tài khoản',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.02,
              ),
            ),
          ),
          _buildInfoField(
            icon: Icons.person_outline,
            label: 'Họ và tên',
            controller: controller.nameController,
            hint: 'Nhập họ và tên',
          ),
          _buildDivider(),
          _buildInfoField(
            icon: Icons.email_outlined,
            label: 'Email',
            controller: TextEditingController(
              text: controller.user.value?.email ?? '',
            ),
            hint: 'Email của bạn',
            readOnly: true,
            enabled: false,
          ),
          _buildDivider(),
          _buildInfoField(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            controller: controller.phoneController,
            hint: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  readOnly: readOnly,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 15,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(
        height: 1,
        color: Color(0xFFEAEAEA),
      ),
    );
  }

  Widget _buildActionsSection(
      BuildContext context, UserProfileController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEAEAEA),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.save_outlined,
            label: 'Lưu thay đổi',
            onTap: () async {
              final success = await controller.saveProfile();
              if (success) {
                Get.back();
              }
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppColors.primary
                      : AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isPrimary ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                    color: isPrimary
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
