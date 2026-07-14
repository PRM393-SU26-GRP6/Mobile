import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:exe101/presentation/features/customer/view/profile/widgets/profile_account_section.dart';
import 'package:exe101/presentation/features/customer/view/profile/widgets/profile_page_header.dart';
import 'package:exe101/presentation/features/customer/view/profile/widgets/profile_save_section.dart';
import 'package:exe101/presentation/features/customer/view/profile/widgets/profile_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserProfileController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (controller.error.value.isNotEmpty &&
              controller.user.value == null) {
            return Center(
              child: FilledButton.icon(
                onPressed: controller.loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử tải lại hồ sơ'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const ProfilePageHeader(),
              ProfileSummaryCard(user: controller.user.value),
              const SizedBox(height: 24),
              ProfileAccountSection(controller: controller),
              const SizedBox(height: 24),
              ProfileSaveSection(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}
