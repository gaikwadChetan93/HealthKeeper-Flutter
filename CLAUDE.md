# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Health Keeper is a Flutter health-tracking app for families, migrated from an Android (Jetpack Compose) app. It is **UI-only** — all data comes from mock/dummy data in `lib/core/mock/mock_data.dart`. No networking, databases, auth logic, or business logic.

## Build & Run Commands

```bash
flutter pub get            # Install dependencies
flutter run                # Run debug
flutter run -d <device>    # Run on specific device
flutter build apk --release   # Android release
flutter build ios --release    # iOS release
flutter test               # Run all tests
flutter test test/<file>   # Single test file
flutter analyze            # Lint
dart format .              # Format code
```

## Architecture

### Config-driven health module system
The app manages 20 health modules (Blood Pressure, Appointments, Allergies, etc.) through a **config-driven generic framework**:
- `lib/core/config/module_registry.dart` — Registry of all 20 module configs (fields, icons, labels)
- `lib/core/models/field_descriptor.dart` — Sealed class with 9 field types (Text, Number, Date, Enum, etc.)
- `lib/core/models/domain_config.dart` — Abstract config interface per module
- `lib/features/health_records/screens/generic_list_screen.dart` — Shared list screen for all modules
- `lib/features/health_records/screens/generic_form_screen.dart` — Shared form screen with dynamic field rendering
- `lib/features/health_records/screens/generic_detail_screen.dart` — Shared detail screen
- `lib/features/health_records/config/module_screen_config.dart` — Maps moduleKey → title/subtitle/date lambdas for all 20 models

**To add a new health module:** Add a `DomainConfig` subclass in `module_registry.dart`, create a model in `core/models/`, add mock data, add a provider in `module_providers.dart`, and add a `ScreenConfig` entry in `module_screen_config.dart`. No new screens needed.

### State Management — Riverpod
- `lib/core/state/health_record_notifier.dart` — Generic `StateNotifier<HealthRecordState<T>>` for all modules
- `lib/core/state/module_providers.dart` — All 20 module providers (family-parameterized by memberId)
- `lib/core/state/form_state_notifier.dart` — Form data + validation state
- State pattern: `AsyncValue<List<T>>` → `.when(loading: ..., error: ..., data: ...)`, empty = data with empty list

### Navigation — GoRouter
- `lib/app/router.dart` — Full route definitions
- `lib/app/route_constants.dart` — Type-safe route helpers
- Parameterized routes: `/health/:moduleKey/:memberId` serves all 20 modules with one route definition
- ShellRoute for bottom nav (Family Members, Doctors, Settings)

### Theme
- `lib/app/theme/` — Material 3 light+dark themes
- Primary: #4285F4, Secondary: #316CE4
- `vital_module_colors.dart` — Unique bg/icon color pair per vital module
- `app_dimens.dart` — Spacing, radius, elevation constants

### Key conventions
- Widgets must stay under 250 lines — extract sub-widgets
- All models use `const` constructors, no Freezed
- Half-width field pairing logic in `GenericFormScreen` — consecutive `LayoutWidth.half` fields render side-by-side in a Row
- Module categories: `quickHealth` (9 record modules) and `vitalOverview` (11 vital modules)
