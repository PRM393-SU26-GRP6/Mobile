# prm_web

Flutter starter template organized for easier development, maintenance, and debugging.

## Architecture

Project is split by responsibilities:

```text
lib/
  app/                      # app bootstrap and MaterialApp config
  core/
    localization/           # language resources and delegates
    settings/               # app-wide state (theme/locale)
    theme/                  # light/dark theme definitions
  features/
    home/presentation/      # UI pages/widgets for home feature
```

## Built-in features

1. VI/EN language switching
2. Light/Dark mode switching
3. Centralized app-level settings via `AppSettings` (ChangeNotifier)

## Run

```bash
flutter pub get
flutter run
```
