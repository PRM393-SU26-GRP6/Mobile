import 'package:flutter/material.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('vi');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isVietnamese => _locale.languageCode == 'vi';

  void updateTheme(bool enableDarkMode) {
    final nextMode = enableDarkMode ? ThemeMode.dark : ThemeMode.light;
    if (nextMode == _themeMode) return;
    _themeMode = nextMode;
    notifyListeners();
  }

  void updateLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
  }
}
