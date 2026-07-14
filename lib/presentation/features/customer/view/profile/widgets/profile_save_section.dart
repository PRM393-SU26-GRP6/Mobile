import 'package:exe101/presentation/features/customer/controller/user_profile_controller.dart';
import 'package:exe101/presentation/features/customer/view/profile/widgets/profile_action_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSaveSection extends StatelessWidget {
  final UserProfileController controller;

  const ProfileSaveSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.white,
      child: ProfileActionItem(
        icon: Icons.save_outlined,
        label: 'Lưu thay đổi',
        isPrimary: true,
        onTap: () async {
          if (await controller.saveProfile()) Get.back<void>();
        },
      ),
    );
  }
}
