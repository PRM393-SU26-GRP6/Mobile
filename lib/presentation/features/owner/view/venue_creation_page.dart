import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/presentation/features/owner/controller/venue_creation_controller.dart';
import 'package:exe101/presentation/features/owner/view/widgets/venue_creation_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VenueCreationPage extends StatelessWidget {
  const VenueCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueCreationController>();

    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        title: const Text('Tạo sân bóng mới'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: VenueCreationForm(
          controller: controller,
          onSubmit: () => _submit(controller),
        ),
      ),
    );
  }

  Future<void> _submit(VenueCreationController controller) async {
    final venue = await controller.createVenue();
    if (venue == null) return;

    await Get.offNamed(
      AppPages.addField,
      arguments: {
        'venueId': venue.id,
        'venueName': venue.venueName ?? controller.nameController.text,
      },
    );
  }
}
