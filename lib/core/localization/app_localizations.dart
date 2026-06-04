import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('vi'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations is not found in the widget tree.');
    return localizations!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'PitchBook',
      'homeTitle': 'App Settings',
      'intro': 'Architecture-ready starter for scalable development.',
      'languageLabel': 'Language',
      'themeLabel': 'Dark mode',
      'languageEnglish': 'English',
      'languageVietnamese': 'Vietnamese',
      'currentTheme': 'Current theme: {theme}',
      'themeLight': 'Light',
      'themeDark': 'Dark',
    },
    'vi': {
      'appTitle': 'PitchBook',
      'homeTitle': 'Cai dat ung dung',
      'intro': 'Bo khung kien truc de mo rong, de maintain va fix bug.',
      'languageLabel': 'Ngon ngu',
      'themeLabel': 'Che do toi',
      'languageEnglish': 'Tieng Anh',
      'languageVietnamese': 'Tieng Viet',
      'currentTheme': 'Giao dien hien tai: {theme}',
      'themeLight': 'Sang',
      'themeDark': 'Toi',
    },
  };

  String _text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }

  String get appTitle => _text('appTitle');
  String get homeTitle => _text('homeTitle');
  String get intro => _text('intro');
  String get languageLabel => _text('languageLabel');
  String get themeLabel => _text('themeLabel');
  String get languageEnglish => _text('languageEnglish');
  String get languageVietnamese => _text('languageVietnamese');
  String get themeLight => _text('themeLight');
  String get themeDark => _text('themeDark');

  String currentTheme(String theme) => _text('currentTheme').replaceAll('{theme}', theme);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
