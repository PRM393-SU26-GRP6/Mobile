import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/settings/app_settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentTheme = settings.isDarkMode ? l10n.themeDark : l10n.themeLight;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.intro, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            DropdownButtonFormField<Locale>(
              decoration: InputDecoration(
                labelText: l10n.languageLabel,
                border: const OutlineInputBorder(),
              ),
              initialValue: settings.locale,
              items: [
                DropdownMenuItem(
                  value: const Locale('vi'),
                  child: Text(l10n.languageVietnamese),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.languageEnglish),
                ),
              ],
              onChanged: (locale) {
                if (locale != null) {
                  settings.updateLocale(locale);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.themeLabel),
              value: settings.isDarkMode,
              onChanged: settings.updateTheme,
            ),
            Text(
              l10n.currentTheme(currentTheme),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
