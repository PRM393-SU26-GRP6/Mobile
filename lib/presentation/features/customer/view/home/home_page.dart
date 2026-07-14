import 'package:exe101/core/theme/app_theme.dart';
import 'package:exe101/core/theme/app_dimensions.dart';
import 'package:exe101/core/widgets/responsive_content.dart';
import 'package:exe101/presentation/features/auth/controller/auth_controller.dart';
import 'package:exe101/presentation/features/customer/controller/venue_controller.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/customer_home_header.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_filter_bar.dart';
import 'package:exe101/presentation/features/customer/view/home/widgets/venue_results_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final venueController = Get.find<VenueController>();
    final authController = Get.find<AuthController>();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        child: ResponsiveContent(
          maxWidth: AppContentWidth.feed,
          child: Column(
            children: [
              CustomerHomeHeader(authController: authController),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      VenueFilterBar(controller: venueController),
                      Expanded(
                        child: VenueResultsList(controller: venueController),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
