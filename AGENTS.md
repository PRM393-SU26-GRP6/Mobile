# AGENTS.md - Mobile Code Rules

Scope: this file applies to the entire `Mobile/` Flutter project.

This project is a Flutter app using GetX, Dio, Envied, secure storage, and a feature-oriented presentation layer. Any human or AI agent changing this codebase must follow these rules. These are strict rules, not suggestions.

## First Read

Before editing code:

1. Read `ARCHITECTURE.md`.
2. Inspect the feature folder you are changing.
3. Check existing route, binding, controller, model, and widget patterns.
4. Do not read, print, copy, or commit `.env` values.
5. Do not change generated/native/platform files unless the task explicitly requires it.

## Hard Rules

### File Size Limits

New code must stay below these limits:

| File type | Hard limit | Required action if exceeded |
|---|---:|---|
| Page/screen file | 300 lines | Split sections into `widgets/`, `tabs/`, or dialogs |
| Dialog/bottom sheet widget | 120 lines | Split inner content into smaller widgets |
| Reusable widget file | 180 lines | Split by visual responsibility |
| Inline widget/helper inside a page | 30 lines | Move to a dedicated file |
| Controller | 200 lines | Split responsibility or move formatting/helpers out |
| Model file | 250 lines | Split by entity/DTO group |
| Remote API/service file | 250 lines | Split by domain service |

Existing files already violate some limits. Do not make those files larger. If you touch a violating file, either reduce the touched area or extract the related code as part of the change.

Known legacy violations that must not be copied:

- `lib/data/remote/api_service.dart` is too large and mixes many API domains.
- Several page files under `presentation/features/**/view/` are still too large.
- Some views call `Get.put`, `Get.find<ApiServiceImpl>`, or API methods directly.
- `main.dart` currently contains `ApiErrorHandler`; do not add more utility logic there.

### API and Data Access

Do not add new endpoints to `lib/data/remote/api_service.dart`.

For any new API domain or meaningful endpoint group:

1. Create a focused remote service under `lib/data/remote/`.
   - Example: `booking_api_service.dart`, `payment_api_service.dart`, `venue_api_service.dart`.
2. Keep Dio/auth/header/error parsing in data layer.
3. Expose business-friendly methods through a repository under `lib/domain/repositories/` when used by controllers.
4. Controllers call repositories or focused services, not raw Dio.
5. Views never call API services directly.

Allowed exception: when fixing a tiny bug in an existing method inside `api_service.dart`, keep the change minimal. Do not add unrelated endpoints.

### GetX Dependency Rules

Dependency registration belongs in bindings.

Use:

- `lib/presentation/features/<feature>/binding/<feature>_binding.dart`
- `Get.lazyPut` for route-scoped controllers.
- `Get.put` only for true app-level singletons or when an existing binding pattern requires it.

Avoid:

- `Get.put(...)` inside a `build()` method.
- Creating controllers in views when the route already has a binding.
- Calling `Get.find<ApiServiceImpl>()` directly from widgets for network work.
- Hard-coded route strings in UI. Use `AppPages` constants.

### Feature Folder Rules

Presentation code must stay feature-local.

Use this structure:

```text
lib/presentation/features/<feature>/
  binding/
  controller/
  shared/
  view/
    <sub_feature>/
      <page>.dart
      widgets/
      tabs/
```

Rules:

- Put page-specific widgets in the nearest `widgets/` folder.
- Put tab widgets in `tabs/`.
- Put role/feature reusable helpers in feature-local `shared/`.
- Do not create broad global shared folders unless the same code is used across multiple top-level features.
- Do not drop many unrelated files directly into `view/`.

Current accepted local shared folders:

- `lib/presentation/features/customer/shared/`
- `lib/presentation/features/owner/view/shared/`

### UI Rules

Pages should orchestrate layout only.

Views may:

- Read reactive controller state with `Obx`.
- Trigger controller methods.
- Navigate using `AppPages`.
- Render loading, empty, error, and success states.

Views must not:

- Build large inline dialog trees.
- Parse API JSON.
- Own business logic.
- Mutate secure storage.
- Build raw request payloads for backend APIs.
- Contain long `onPressed` blocks with validation, network calls, and navigation mixed together.

Widget extraction triggers:

- A UI section has a clear name.
- A widget/helper is reused twice.
- A dialog or sheet is over 30 inline lines.
- A page starts mixing header, list item, form, dialog, and state widgets in one file.

### State and Controller Rules

Use GetX controllers for screen state and workflow state.

Controllers may:

- Hold `Rx`, `Rxn`, `RxList`, `RxMap`.
- Own `TextEditingController` when it belongs to the screen flow.
- Call repositories/services.
- Convert errors to user-facing state/messages.
- Dispose Flutter controllers in `onClose`.

Controllers must not:

- Build widgets.
- Contain large formatting/color/icon mapping tables used by multiple widgets.
- Directly duplicate API parsing logic.
- Silently swallow errors unless the UX intentionally ignores them.

Move reusable formatting/status mapping to:

- `core/utils/` for app-wide utilities.
- `<feature>/shared/` for feature-local helpers.
- model getters only when the display label is intrinsic to the model and not theme/UI-specific.

### Models and JSON

Use typed models for API data. Do not pass unstructured `Map<String, dynamic>` through presentation code.

Model rules:

- Keep `fromJson` tolerant of backend shape differences when needed.
- Keep UI colors/icons out of domain models.
- Keep DTO names consistent with existing code if backend naming already uses `Dto`.
- Add `toJson` only when the app sends that model/request body.

### Routing

All named routes live in `lib/core/routing/app_pages.dart`.

When adding a route:

1. Add a route constant.
2. Add a `GetPage`.
3. Attach the correct binding.
4. Navigate with `Get.toNamed(AppPages.someRoute, arguments: ...)`.
5. Document expected `Get.arguments` shape in the destination controller or page.

Do not use hard-coded strings such as `'/owner/slot-management'` in new code.

### Environment and Generated Files

Secrets:

- `.env` and `.env.*` are ignored and must not be committed.
- Do not paste env values into logs, docs, tests, or screenshots.
- `Env.baseUrl` comes from `lib/core/config/env.dart`.

Generated files:

- Do not manually edit `*.g.dart`.
- If `env.g.dart` is missing or stale, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Error Handling and Logging

Do:

- Convert Dio errors to user-friendly messages.
- Show loading/error/empty states.
- Use `debugPrint` only for temporary diagnostics.
- Remove temporary debug output before finishing.

Do not:

- Use `print()` in committed code.
- Add broad `catch (_) {}` without a comment explaining why the error is intentionally ignored.
- Import `main.dart` from controllers just to access helpers.
- Throw generic `Exception` from normal domain flow when a typed `AppException` or result state is more appropriate.

### Formatting and Quality Gates

Before finishing a code change, run the most relevant checks:

```bash
dart format lib test
flutter analyze
```

If generated env files are needed:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For dependency changes:

```bash
flutter pub get
flutter analyze
```

For Android build-sensitive changes:

```bash
flutter build apk --debug
```

If a command cannot run in the current environment, state that clearly in the handoff.

## Task Playbooks

### Implementing a Feature

1. Identify the nearest top-level feature: `auth`, `customer`, `owner`, or a new feature.
2. Add/update domain models first if API shape changes.
3. Add focused data service/repository methods.
4. Register dependencies in binding.
5. Add controller state/actions.
6. Build page shell under `view/<sub_feature>/`.
7. Extract widgets early; do not wait for the page to become huge.
8. Add route in `AppPages` if navigation is needed.
9. Run format/analyze.

### Fixing a Bug

1. Reproduce or inspect the failing flow.
2. Find the smallest responsible layer.
3. Fix the bug at the owning layer, not the symptom layer.
4. Avoid broad refactors unless the file is already violating size/responsibility and the touched code can be safely extracted.
5. Run targeted verification.

### Debugging

1. Start from route -> binding -> controller -> data service.
2. Check `Get.arguments` shape.
3. Check controller registration (`Get.isRegistered`) only for diagnosis, not as a permanent workaround in views.
4. Check API response shape against `swagger.json` or `FE_API_FLOW.md`.
5. Remove temporary logs before finishing.

### Refactoring

Refactors must preserve behavior.

Allowed refactors:

- Extract widget/dialog/helper from a large page.
- Move duplicated formatting to feature `shared/`.
- Split domain-specific API methods out of `api_service.dart`.
- Replace hard-coded route strings with `AppPages` constants.

Disallowed refactors without explicit approval:

- Changing state management library.
- Replacing GetX routing.
- Moving broad folder structures across multiple features at once.
- Changing backend endpoint contracts.
- Editing platform folders (`android/`, `ios/`, etc.) for presentation-only work.

## Pull Request / Handoff Checklist

Before handing off:

- No `.env` value was read, printed, or committed.
- No new page exceeds 300 lines.
- No new endpoint was added to `api_service.dart`.
- New routes use `AppPages`.
- New controllers are registered in bindings.
- Views do not call network services directly.
- Large widgets/dialogs are extracted.
- `dart format` ran for touched Dart files.
- `flutter analyze` ran, or the reason it could not run is documented.

