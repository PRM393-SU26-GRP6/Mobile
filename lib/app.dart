import 'package:exe101/core/routing/app_pages.dart';
import 'package:exe101/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Theme (use light green theme matching design)
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // Routing
      initialRoute: AppPages.splash,
      getPages: AppPages.pages,

      // Global settings
      debugShowCheckedModeBanner: false,
    );
  }
}
