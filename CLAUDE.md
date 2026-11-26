# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Health Keeper is a Flutter health-tracking app for families, migrated from an Android (Jetpack Compose) app and since redesigned. There is **no backend**: all records come from mock data in `lib/core/mock/mock_data.dart`, auth is simulated (`features/auth/providers/auth_provider.dart`), and notifiers fake latency with `Future.delayed`. The only real device integrations are:
- `shared_preferences` — persists the active family member
- `camera` + `google_mlkit_text_recognition` — on-device document scanning/OCR (`features/documents/scanner/`); needs camera permissions in `AndroidManifest.xml` / `Info.plist`, and Android `minSdk` ≥ 24

## Build & Run Commands

The Flutter SDK lives at `/Users/chetangaikwad/AndroidStudioProjects/Flutter SDK/flutter/bin` (path contains a space — quote it if `flutter` isn't on PATH).

```bash
flutter pub get
flutter run -d <device>
flutter analyze            # Lints: flutter_lints + prefer_const_*, prefer_single_quotes, avoid_print
flutter test               # Only test/widget_test.dart (app smoke test) exists
flutter test test/widget_test.dart
dart format .
```

## Architecture

### Config-driven health modules
20 health modules are driven by one generic framework instead of per-module screens:
- `core/config/module_registry.dart` — a `DomainConfig` subclass per module (fields, icon, labels, `domainKey`, `category`). Categories: `quickHealth` (10 record types: medical_visit, appointment, allergy, vaccine, medication, prescription, lab_result, medical_history, surgery, radiology_result) and `vitalOverview` (10 vitals: blood_pressure, weight, height, blood_glucose, heart_rate, temperature, oxygen_saturation, sleep, exercise, hydration).
- `core/models/field_descriptor.dart` — sealed `FieldDescriptor` hierarchy (Text, Number, Date, DateTime, Time, Enum, Boolean, …) rendered by `features/health_records/widgets/field_renderer.dart`. In `GenericFormScreen`, consecutive `LayoutWidth.half` fields are paired side-by-side in a Row.
- `features/health_records/config/module_screen_config.dart` — maps `moduleKey` → provider getter plus title/subtitle/date lambdas. This is the lookup most cross-module code uses (`ModuleScreenConfig.getConfig(key).getProvider(memberId)`).
- `features/health_records/screens/generic_{list,form,detail}_screen.dart` — shared screens for all modules.

**Adding a module:** model in `core/models/`, `DomainConfig` in `module_registry.dart`, mock data, provider in `module_providers.dart`, entry in `module_screen_config.dart`. For a vital, also add a `VitalEntrySpec` (`features/vitals/config/vital_entry_spec.dart`, keypad entry fields/chips) and a `VitalChartConfig` (`vital_chart_config.dart`, units + health zones from `core/models/health_zone_definitions.dart`).

### Vitals vs. records
Record modules use the generic list/form/detail screens. Vitals have their own flow under `features/vitals/`: a keypad entry screen (`/vitals/:moduleKey/:memberId/entry`) and a chart/detail screen (`/vitals/:moduleKey/:memberId/chart`) built on `fl_chart`.

### State — Riverpod (StateNotifier)
- `core/state/module_providers.dart` — one `StateNotifierProvider.family` per module keyed by `memberId`, plus `familyMembersProvider`.
- `core/state/health_record_notifier.dart` — generic notifier; state holds `AsyncValue<List<T>> records` (use `.when(...)`; empty = data with empty list).
- `core/state/active_person_provider.dart` — the "currently managed" family member is app-level state (persisted). Screens fall back to it when no `memberId` is in the route; family providers are still called with an explicit id.
- `core/state/record_lookup.dart` — `/health/:moduleKey/detail/:recordId` has no memberId, so `findRecordById` scans every member's provider.
- `features/home/state/home_timeline.dart` — Home activity feed is built by fanning out over all quickHealth providers and merging client-side.

### Navigation — GoRouter
- `app/router.dart` (routes) and `app/route_constants.dart` (`Routes` constants/helpers).
- Flow: splash → welcome → sign-in → `ShellRoute` with `BottomNavShell` tabs: Home, Records, Vitals, Documents. Family, Doctors, Settings, search, person picker, privacy, backup, subscription, etc. are top-level routes pushed over the shell.
- One parameterized route set (`/health/:moduleKey/:memberId[/add|/edit/:recordId]`) serves all modules.

### Theme
- `app/theme/` — Material 3 light/dark. Redesign palette is forest green `#1E4D3B` on bone `#F2EEE6`; source of truth is the design export `Health Keeper.dc.html`. Use role-named tokens (`AppColors.ink`, surface, border, muted) rather than hex literals.
- Font: Manrope via `google_fonts`.
- Per-category color maps: `vital_module_colors.dart`, `record_category_colors.dart`, `document_colors.dart`; spacing/radius in `app_dimens.dart`, shadows in `app_shadows.dart`.
- Theme mode is controlled by `core/state/theme_provider.dart`.
- Prefer the shared `hk_*` widgets in `core/widgets/` (card, chip, list tile, avatar, skeleton, empty state, primary button) for new UI.

### Conventions
- Keep widgets under ~250 lines by extracting sub-widgets (several older screens, e.g. `vital_detail_screen.dart`, `welcome_screen.dart`, exceed this — don't grow them further).
- Models are hand-written with `const` constructors — no Freezed/codegen.
