import 'package:flutter/material.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../booking/presentation/pages/booking_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return BookingPage(settings: settings);
  }
}
