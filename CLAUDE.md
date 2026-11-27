# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Health Keeper is a Flutter health-tracking app for families. It is a **thin online client** of the Health Keeper API (Python/FastAPI, repo `healthkeeper-backend`): sign-in, family members and all health records are read from and saved to the API. No health data is stored on the device; only the refresh token is kept, in the platform keystore (`flutter_secure_storage`). Doctors are real data too (`lib/core/state/doctor_providers.dart`); records link to a saved doctor through the module's doctor field (`lib/core/records/doctor_fields.dart`).

## Build & Run Commands

```bash
flutter pub get            # Install dependencies
flutter run                # Run debug (talks to http://10.0.2.2:8000 on the Android emulator)
flutter run --dart-define=API_BASE_URL=https://api.example.com   # Point at another API
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
- `lib/core/records/record_format.dart` — Converts form values ↔ API payload, and builds list titles/subtitles and detail text per module

Records are generic: `RecordItem` holds the module key and a `payload` map keyed by the module's field keys. The backend validates payloads against the same field definitions (generated from `module_registry.dart` by the backend's `scripts/extract_modules.py`).

**To add a new health module:** Add a `DomainConfig` subclass in `module_registry.dart`, regenerate the backend's `definitions.json`, and add title/subtitle cases in `record_format.dart`. No new screens or models needed.

### API, sign-in and state — Riverpod
- `lib/core/api/api_client.dart` — HTTP client: bearer token, automatic refresh on 401, `ApiException` from the API's error envelope, `If-Match` on updates, `Idempotency-Key` on creates
- `lib/core/api/api_config.dart` — API base URL (`--dart-define=API_BASE_URL`; debug defaults to the local backend)
- `lib/core/auth/auth_controller.dart` — Sign-in state (`starting` / `signedOut` / `signedIn` + `/v1/me`), dev sign-in (debug builds, local backend only), consents, sign-out
- `lib/core/state/api_providers.dart` — `membersProvider`, `recordsProvider((memberId, module, query))` with paging, `recordProvider(id)`, `summaryProvider(memberId)`, `recordActionsProvider` (create/update/delete + refresh)
- `lib/core/state/form_state_notifier.dart` — Form data + validation state (server field errors via `setErrors`)
- State pattern: `AsyncValue<List<T>>` → `.when(loading: ..., error: ..., data: ...)`, empty = data with empty list

### Navigation — GoRouter
- `lib/app/router.dart` — Full route definitions; `authRedirect` sends people to splash → welcome/sign-in → consent → create profile → app. There is no guest mode.
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
- Module categories: `quickHealth` (record modules) and `vitalOverview` (vital modules). `lab_result` is shown as "Soon" until lab values and report upload are built.
- IDs from the API are UUID strings (members, records).
- Family members must be 18+ for now; adding someone other than yourself needs the attestation checkbox.
