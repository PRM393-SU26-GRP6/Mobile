# ARCHITECTURE.md - Mobile App Architecture

This document describes the intended architecture of the `Mobile/` Flutter app. It is the source of truth for implementing features, fixing bugs, debugging, and maintaining the codebase.

## Overview

The app is a Flutter application for football venue booking and management. It uses:

- Flutter Material UI.
- GetX for routing, dependency injection, and reactive state.
- Dio for HTTP.
- Envied for environment variables.
- Flutter Secure Storage for auth/session tokens.

The current codebase is organized into four main layers:

```text
lib/
  core/
  data/
  domain/
  presentation/
```

The desired direction is a feature-oriented presentation layer with clear boundaries between UI, controller state, domain models/repositories, and remote API clients.

## Runtime Flow

```text
main.dart
  -> initializes Dio, API singletons, and app-level dependencies
  -> runApp(App)

App
  -> GetMaterialApp
  -> AppPages.initialRoute
  -> AppPages.pages

Route
  -> Binding registers controllers/services for the route
  -> Page reads controller state with Obx
  -> Controller calls repository/service
  -> Data service calls backend with Dio
  -> Model parses JSON
  -> Controller updates Rx state
  -> View re-renders
```

The page should be the thinnest layer. Business decisions and API workflows belong in controllers/repositories/services.

## Layer Responsibilities

### `core/`

App-wide infrastructure and constants.

Current folders:

- `core/config/`: environment access through `Env`.
- `core/constant/`: app constants.
- `core/exception/`: app-level exception types.
- `core/routing/`: GetX route table in `AppPages`.
- `core/theme/`: app colors and theme.
- `core/utils/`: app-wide utilities.

Use `core/` only for code that is truly shared across multiple top-level features. Do not put feature-specific helpers here.

### `data/`

External data access and local data infrastructure.

Current folders:

- `data/remote/`: Dio-backed API services.
- `data/local/`: local singleton/storage placeholders.

Current debt: `data/remote/api_service.dart` is too large and owns many domains. New API work must not grow this file. Split new or touched API areas into focused services.

Target API shape:

```text
lib/data/remote/
  dio_client.dart                 # optional future shared Dio/auth setup
  auth_api_service.dart
  venue_api_service.dart
  booking_api_service.dart
  payment_api_service.dart
  notification_api_service.dart
  chat_api_service.dart
```

Each service owns one backend domain. It returns typed models or DTOs, not raw maps.

### `domain/`

Typed business data and repository interfaces/implementations used by controllers.

Current folders:

- `domain/models/`: models and DTOs with `fromJson`/`toJson`.
- `domain/repositories/`: repository classes that hide data-service details from controllers.

Rules:

- Models describe backend/app data, not UI styling.
- Repositories expose business-friendly methods.
- Controllers should prefer repositories over raw remote services when a repository exists.
- New repeated workflow logic should move into a repository instead of being copied across controllers.

### `presentation/`

UI, route bindings, and GetX controllers.

Current top-level features:

```text
presentation/features/
  auth/
  customer/
  owner/
  splash/
```

Each feature should follow this shape:

```text
presentation/features/<feature>/
  binding/
    <feature>_binding.dart
  controller/
    <screen_or_flow>_controller.dart
  shared/
    <feature>_helpers.dart
    <feature>_constants.dart
    <feature>_decorations.dart
  view/
    <sub_feature>/
      <page>.dart
      widgets/
      tabs/
```

For `owner`, the existing shared folder is currently under `view/shared/`. Keep using the local convention unless a broader refactor moves it.

## Dependency Injection

GetX bindings are the dependency boundary for presentation features.

Examples:

- `auth/binding/auth_binding.dart`
- `customer/binding/customer_binding.dart`
- `owner/binding/owner_binding.dart`
- `splash/binding/splash_binding.dart`

Expected flow:

```text
AppPages route
  -> Binding.dependencies()
  -> Get.lazyPut/Get.put controller/repository/service
  -> Page uses Get.find<Controller>()
```

Rules:

- Put route-scoped controllers in bindings.
- Avoid creating controllers inside widgets.
- Avoid `Get.put` inside `build()`.
- Use `Get.lazyPut` for controllers unless immediate construction is required.
- Use app-level registration only for long-lived infrastructure such as Dio/API clients/auth session services.

## Routing

All route names and pages live in:

```text
lib/core/routing/app_pages.dart
```

Route rules:

- Add a static route constant for every named route.
- Add a `GetPage` with the correct binding.
- Navigate with `AppPages.<routeName>`, not string literals.
- Keep route arguments small and documented.
- Prefer passing IDs or typed models, not loosely structured maps, unless the destination already expects a map.

Current initial route:

```text
AppPages.splash
```

## State Management

This codebase uses GetX reactive state.

Common patterns:

- `final isLoading = false.obs;`
- `final error = ''.obs;`
- `final selectedItem = Rxn<Model>();`
- `final items = <Model>[].obs;`
- `Obx(() => ...)` in views.

Controller responsibilities:

- Own screen state.
- Load data.
- Submit forms.
- Validate workflow-level state.
- Expose simple methods for views.
- Dispose `TextEditingController` in `onClose`.

View responsibilities:

- Render controller state.
- Trigger controller actions.
- Navigate.
- Show UI states.

Views should not call Dio/API services directly.

## API and Auth Architecture

Current bootstrap:

- `main.dart` creates Dio with `Env.baseUrl`.
- `ApiServiceImpl` stores and reads tokens using Flutter Secure Storage.
- Auth flows persist access token, refresh token, role, and user id.

Target direction:

```text
Env
  -> Dio/client setup
  -> focused remote service
  -> repository
  -> controller
  -> view
```

New endpoint rule:

- Do not add new endpoint methods to the monolithic `api_service.dart`.
- Add a focused service under `data/remote/`.
- Add/extend a repository under `domain/repositories/` if a controller consumes it.
- Return typed models from `domain/models/`.

For existing endpoint bugs in `api_service.dart`, minimal local fixes are allowed. Larger endpoint work should extract that domain first.

## Feature Structure Guide

### Auth

Current path:

```text
lib/presentation/features/auth/
  binding/
  controller/
  view/
  view/widgets/
```

Auth owns:

- Login.
- Register.
- OTP verification.
- Role selection.
- Logout navigation.

Auth controllers should not import `main.dart` for helpers. Error handling helpers should live in `core/exception/`, `core/utils/`, or a focused error handler file.

### Customer

Current path:

```text
lib/presentation/features/customer/
  binding/
  controller/
  shared/
  view/
    booking/
    cart/
    home/
    map/
    messages/
    notifications/
    orders/
    profile/
```

Customer owns:

- Venue discovery/detail.
- Booking creation/history.
- Payments.
- Reviews.
- Notifications.
- Messages/chat.
- Profile.

Use `customer/shared/` for customer-only helpers, constants, decorations, and repeated display mapping.

### Owner

Current path:

```text
lib/presentation/features/owner/
  binding/
  controller/
  view/
    booking/
    field/
    home/
    shared/
    slot_management/
```

Owner owns:

- Owner home dashboard.
- Venue creation/management.
- Field creation/detail.
- Slot management.
- Booking management.

Use `owner/view/shared/` for owner-only helper functions, dialogs, labels, and formatting.

### Splash

Current path:

```text
lib/presentation/features/splash/
  binding/
  controller/
  view/
```

Splash owns:

- Initial auth/session check.
- Redirecting to login, customer home, or owner home.

## UI Composition Rules

Pages should be shells. A good page file usually contains:

- `Scaffold`.
- Top-level layout.
- `Obx` state switches.
- Calls to extracted widgets.
- Small event handlers that delegate to controllers.

Extract widgets when:

- A section is over 30 lines.
- A dialog/sheet is over 30 lines.
- A widget is reused.
- A page is approaching 300 lines.
- A section has its own visual responsibility.

Preferred extraction:

```text
view/home/home_page.dart
view/home/widgets/home_venue_card.dart
view/home/widgets/home_search_bar.dart
view/home/widgets/home_filter_chip.dart
```

Avoid:

```text
view/home_page.dart                 # huge mixed page
view/widgets.dart                   # unrelated widget dump
view/shared_widgets.dart            # vague shared bucket
```

## Error, Loading, and Empty States

Every network-backed screen should handle:

- Initial loading.
- Refresh/loading-more if paginated.
- Empty data.
- User-friendly error.
- Retry path when useful.

Controllers should expose state clearly:

```dart
final isLoading = false.obs;
final isLoadingMore = false.obs;
final error = ''.obs;
final hasMore = true.obs;
```

Views should render those states, not infer them from raw API details.

## Environment and Secrets

`.env` is used by Envied and must stay local.

Rules:

- Never commit `.env` or `.env.*`.
- Never paste env values into docs or logs.
- Never manually edit generated `*.g.dart`.
- Generate env code with:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The repo ignores `.env`, `.env.*`, and `*.g.dart`.

## Existing Technical Debt

These are known problems. They document what to fix over time, not patterns to copy.

### Monolithic API Service

`lib/data/remote/api_service.dart` mixes auth, venues, fields, slots, bookings, payments, chats, users, reviews, and notifications.

Target: split into domain services and repositories.

### Large Pages

Several page files still exceed the desired limits. New work must extract sections instead of making those files larger.

### Direct View Dependencies

Some views currently call `Get.find<ApiServiceImpl>()` or register controllers directly. New work should move that dependency usage into bindings/controllers.

### Utility Placement

Some helpers live in places that make imports awkward, such as controllers importing `main.dart` for error handling. New helpers should live in `core/` or feature `shared/`.

### Debug Output

Some debug prints exist in data/API code. New committed code must not add `print()` and should remove temporary debug logs.

## Adding a New Feature

Use this checklist:

1. Pick the feature owner: `auth`, `customer`, `owner`, or a new top-level feature.
2. Add models in `domain/models/`.
3. Add a focused API service in `data/remote/`.
4. Add repository methods in `domain/repositories/`.
5. Add controller in `presentation/features/<feature>/controller/`.
6. Register controller/repository in the feature binding.
7. Add page under `view/<sub_feature>/`.
8. Add widgets under the nearest `widgets/`.
9. Add route in `AppPages`.
10. Run format and analyze.

## Changing an Existing Feature

Use this checklist:

1. Read the current page, controller, binding, model, and route.
2. Identify the owning layer for the change.
3. Keep behavior changes separate from extraction/refactor changes when possible.
4. If the touched page is over 300 lines, extract the touched UI section.
5. If the touched API service area is in `api_service.dart`, do not add new endpoint groups there.
6. Keep imports local and specific.
7. Run verification.

## Verification

Default checks:

```bash
dart format lib test
flutter analyze
```

When env generation is affected:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

When dependencies change:

```bash
flutter pub get
flutter analyze
```

When platform/build behavior might be affected:

```bash
flutter build apk --debug
```

If a check cannot run locally, document the reason clearly.

