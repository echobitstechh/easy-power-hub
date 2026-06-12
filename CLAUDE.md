# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Run the app
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Regenerate Stacked code (routes, locator, dialogs, bottom sheets)
dart run build_runner build --delete-conflicting-outputs

# Regenerate Freezed / JSON serializable models only
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/features/auth/**"

# Lint
flutter analyze
```

**Android build notes (Windows):**
- `android/gradle.properties` must set `org.gradle.java.home=C:\\Program Files\\Java\\jdk-17` (macOS path is committed — keep the Windows path uncommented when building locally).
- `android/app/build.gradle` signing config is guarded by `keystorePropertiesFile.exists()` — `key.properties` is not committed and only needed for release builds.
- If Gradle fails with a lock error, kill Java processes and delete the `build/` directory.

## Architecture

**Framework:** Stacked MVVM (code-generated). Every screen is a `StackedView<ViewModel>` paired with a `BaseViewModel` subclass. Stacked generates the DI locator, router, bottom sheet UI, and dialog UI from `lib/app/app.dart`.

**Dependency injection:** `locator` (GetIt) via `lib/app/app.locator.dart`. All services are registered as `LazySingleton`. After adding a service to `app.dart`, run `build_runner`.

**Routing:** Defined in `lib/app/app.dart` under `@StackedApp(routes: [...])`. Generated into `app.router.dart` — never edit that file directly. Use `locator<NavigationService>().navigateTo(Routes.xxx)` or the generated extension methods on `NavigationService`.

**Global state:** `lib/state.dart` holds top-level `ValueNotifier`s (`cart`, `profile`, `userLoggedIn`, `globalCategories`, etc.) consumed via `ValueListenableBuilder` across features. This sidesteps the ViewModel for truly cross-feature reactive state.

**Network:** `ApiService` wraps Dio with auth interceptors. All API calls return `ApiResponse`. The base URL lives in `lib/core/utils/config.dart` (`AppConfig.baseUrl`). Paystack keys are fetched from Firebase Remote Config with fallbacks in `AppConfig`.

**Storage:** `LocalStorage` (Sembast NoSQL) persists auth tokens, theme preference, onboarding flag. Key names are in `lib/core/utils/local_store_dir.dart`.

**Repository pattern:** `lib/core/data/repositories/repository.dart` is a single fat repository for all data access; `repository_interface.dart` defines the contract.

**Theme:** `lib/ui/common/theme.dart` defines `easyPhLightTheme` / `easyPhDarkTheme`. Colors are in `lib/ui/common/app_colors.dart`. `ThemeService` persists the user's preference and notifies `MainApp` via `ListenableServiceMixin`.

**Code generation targets** — run `build_runner` after touching any of these:
- `lib/app/app.dart` — routes, services, dialogs, bottom sheets
- Any `*.freezed.dart` source model (e.g. `user_dto.dart`)
- Any `*.g.dart` JSON serializable model

## Feature Map

| Feature | Entry view | Notes |
|---|---|---|
| Startup | `StartupView` | Checks auth token, routes to onboarding or home |
| Onboarding | `OnboardingView` | Single-screen, shown once via `LocalStorageDir.onboarded` flag |
| Auth | `Login`, `Register`, `OTPView`, `EnterEmailView` | OTP flow; Google Sign In supported |
| Home shell | `HomeView` | Bottom nav host; tabs are Dashboard, Shop, Cart, Services, Profile |
| Dashboard | `DashboardView` | Product feed with ads carousel, category grid, tags, brands |
| Shop | `ShopView` | Filterable product list by category or tag |
| Cart / Checkout | `CartView` → `CheckoutView` | Paystack payment; deep link `easyph://payment-success` triggers success view |
| Profile | `ProfileView` | Orders, shipping addresses, referrals, support, password change |
| Services | `ServicesView` | Service request flow |

## Stacked CLI shortcuts

```bash
# Add a new view + viewmodel
stacked create view <name>

# Add a new service
stacked create service <name>

# Add a new bottom sheet
stacked create bottom_sheet <name>
```
