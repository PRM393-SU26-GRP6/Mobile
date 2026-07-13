import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_edit_controller.dart';
import 'package:exe101/presentation/features/owner/view/venue_edit/widgets/venue_edit_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueEditPage extends StatelessWidget {
  const VenueEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueEditController>();
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Cap nhat venue'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: VenueEditForm(
          controller: controller,
          onSave: () async {
            final venue = await controller.save();
            if (venue != null) Get.back(result: venue);
          },
        ),
      ),
    );
  }
}
