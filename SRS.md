# LIORA — System Requirements & Reproducible Implementation Specification (SRS)

**Last updated:** 2026-02-09

Purpose: This single-file SRS documents the full structure, behavior, dependencies, configuration, run/test instructions and an update diary for the LIORA Flutter project. The file is intentionally exhaustive so a capable AI agent or engineer can replicate, validate, modify or rebuild the app from scratch.

---

**0. Project Identification (LOCKED)**
- Product Name: LIORA
- Spelling Authority: L-I-O-R-A
- App Nickname: liora 2.0
- Primary Language: Dart
- UI Framework: Flutter
- Platform primary: Android (also web: Chrome supported)
- GitHub: https://github.com/alwin-m/liora
- Official contact: alwinmadhu7@gmail.com

**Firebase (locked identifiers)**
- Project ID: `liora-43381`
- Project Number: `105498158234`
- Android App ID: `1:105498158234:android:962e76b41469788bb9ab23`
- Android package name: `com.liora.liora`
- Storage bucket: `liora-43381.firebasestorage.app`

---

**1. High-level Intent & Boundary**
- LIORA is a non-medical menstrual wellness companion. It must never diagnose or suggest treatment. All health data (period dates, symptoms, predictions) must stay on-device encrypted.
- Firebase is used for Authentication only (email/UID), not for storing health data.

---

**2. Architecture Overview**
- Flutter UI (Material-based, soft pastel theme)
- State management: `provider`
- Local storage: `hive` + `hive_flutter` + `flutter_secure_storage` (encryption key stored in secure storage)
- Prediction engine: deterministic on-device algorithm in `lib/core/engine/prediction_engine.dart`
- Firebase: `firebase_core`, `firebase_auth` (web config in `lib/firebase_options.dart`)
- Notifications: mobile-only (platform notification implementations). Web uses a graceful stub — web does not attempt to call `flutter_local_notifications`.

---

**3. Dependency Snapshot (as used in repo)**
(See `pubspec.yaml` for exact versions; these were the versions last used)
- flutter sdk
- firebase_core (3.15.2)
- firebase_auth (5.1.0)
- hive, hive_flutter
- flutter_secure_storage
- provider
- table_calendar
- timezone
- intl
- google_fonts
- animations
- cupertino_icons

Note: Cloud Firestore was explicitly removed to comply with privacy SRS.

---

**4. File & Folder Inventory (project tree + per-file description)**
This lists repo files and a concise description of their purpose. Paths are workspace-relative.

- analysis_options.yaml — Dart static analysis settings.
- README.md — (project README) high-level instructions.
- SETUP_GUIDE.md — (project-specific environment / setup notes)
- pubspec.yaml — Flutter dependencies and assets.

- android/ — Android Gradle project and artifacts.
  - android/app/google-services.json — Firebase Android configuration (exists in repo root android app).
  - build.gradle, gradle.properties, gradlew, gradlew.bat, settings.gradle — Android build configuration.

- assets/ — app runtime assets (images, icons, fonts).
  - assets/fonts/
  - assets/icons/
  - assets/images/

- build/ — build outputs (ignored by source control in most cases).

- lib/ — main Dart source code.
  - main.dart
    - App entrypoint. Initializes Flutter bindings, Firebase (with options: `DefaultFirebaseOptions.currentPlatform`), Hive, StorageService, NotificationService. Sets system UI overlay styles and runs `LioraApp()`.
  - firebase_options.dart
    - Generated/edited file containing `DefaultFirebaseOptions` with platform-specific FirebaseOptions. Includes a `web` configuration (apiKey, appId, authDomain) used by web builds.
  - firebase_options.dart (note): Ensure the apiKey and appId are valid for web when deploying; placeholders may exist in repo and must be replaced with actual Firebase console values for auth to succeed.

  - core/
    - engine/
      - prediction_engine.dart
        - Deterministic on-device algorithm for cycle predictions.
        - Inputs: last menstrual period(s), stored period starts, average cycle length and average period length from storage.
        - Outputs: CycleState (currentPhase, currentCycleDay, nextPeriodDate, fertileWindow, confidence score, etc.).
        - Implementation notes: Uses rolling averages, last N cycles (configurable), and simple arithmetic heuristics—no cloud ML.
    - services/
      - storage_service.dart
        - Hive backed encrypted storage. Three boxes: `cycle_data`, `settings`, `user_profile`.
        - Uses `FlutterSecureStorage` for storing the encryption key (encryptedSharedPreferences on Android).
        - Methods for: save/get period starts, period days, symptoms, mood, flow intensity, user profile (DOB, LMP), settings (reminders), export/import JSON, and clear/reset functions.
      - notification_service.dart
        - Web-safe notification service. On mobile this would connect to platform notification libraries; web returns early and acts as a stub.
        - Key methods: init(), schedulePeriodApproachingReminder(), schedulePeriodStartReminder(), scheduleDailyWellnessNudge(), scheduleLogReminder(), rescheduleNotifications(), cancelNotification(s).
        - Note: the repo contains a simplified web-compatible implementation and a comment explaining mobile platform-specific implementations.
      - firebase_sync_service.dart (added)
        - Syncs non-sensitive user profile and settings to Firebase Auth or Realtime DB (only non-health data). Contains explicit privacy warning to never sync health data.
    - theme/
      - liora_theme.dart
        - Contains the color palette (tokens and hex values), gradients, spacing constants, typography using `google_fonts`, shadows, radii, and other UI constants.
  - features/
    - auth/
      - providers/
        - auth_provider.dart
          - Manages FirebaseAuth. Includes:
            - signIn(), signUp(), signOut(), sendPasswordResetEmail(), deleteAccount(), input validators, friendly/gentle error mapping from Firebase codes to helpful messages.
            - Validation functions: `validateEmail`, `validatePassword`, `validateSignUpInputs`, `validateSignInInputs` to provide client-side messages before contacting the server.
            - After signup, profile sync calls `FirebaseSyncService` to update non-sensitive profile fields.
      - screens/
        - splash_screen.dart — startup branding, auth gating, navigation to onboarding/home.
        - login_screen.dart — sign-in UI with validation and friendly errors. Improved to show specific errors.
        - signup_screen.dart — sign-up UI with client validation, two-password matching, uses provider validation.
      - widgets/
        - auth_button.dart — stylized button with loading state.
        - auth_text_field.dart — stylized input with optional password masking and validation.
    - cycle/
      - providers/
        - cycle_provider.dart
          - Coordinates `PredictionEngine`, `StorageService`, and `NotificationService`.
          - Exposes `refresh()`, `logPeriodStart()`, `togglePeriodDay()` and day helpers for UI.
    - home/
      - screens/
        - home_screen.dart — main dashboard containing the calendar, status cards, header and navigation drawer.
      - widgets/
        - calendar_view.dart — interactive calendar with infinite scroll; uses color tokens from theme and calls provider to render day types.
        - cycle_status_card.dart — primary card showing next period, confidence, and actions.
        - day_details_sheet.dart — bottom sheet for day detail and toggles (period day, symptoms).
        - home_header.dart — header with quick actions.
        - profile_drawer.dart — navigation drawer with profile and settings.
    - onboarding/
      - providers/
        - onboarding_provider.dart — manages the 5-step onboarding state and stores user profile into `StorageService`.
      - screens/
        - onboarding_screen.dart — AirPods-style bottom-sheet flow with five steps: DOB, LMP, average cycle length, period length, wellness flags.
      - widgets/
        - date_picker_step.dart — date selection step component.
        - cycle_length_step.dart — cycle length input step.
        - wellness_flags_step.dart — multi-select symptom flags.
        - onboarding_step.dart — base step container.
    - shop/
      - screens/
        - wellness_shop_screen.dart — UI for curated wellness content (non-health data), uses theme palette.

  - other app-specific UI files and widgets live under `lib/features/*` with consistent naming patterns. The app uses `provider` consumers and ChangeNotifier providers across screens.

- web/ — web app assets and `index.html` configured for web deploy.

---

**5. Data Architecture & Privacy (SRS locked)**
- Data classification:
  - Email & UID: Firebase Auth (server)
  - All menstrual and health-related data: stored locally in Hive encrypted boxes only
- Forbidden operations:
  - NO Firestore or cloud backups containing cycle/health data
  - NO cloud inference on health data
- Local encryption:
  - AES encryption key generated via `Hive.generateSecureKey()` and stored base64 in `flutter_secure_storage` (AndroidEncryptedSharedPreferences when possible).

---

**6. Prediction Engine (Implementation details)**
- Inputs: last 3–6 period start dates (prefers last N up to a configurable max), average cycle length (fallback default 28), average period length (default 5).
- Algorithm:
  1. Compute rolling average of cycle intervals between consecutive starts.
  2. Predicted next start = lastPeriodStart + rollingAverageDays.
  3. Fertile window = lastPeriodStart + 35%..60% of cycle length (configurable). Ovulation day ≈ 50%.
  4. Confidence score = min(1.0, numberOfCycles / maxCyclesForAverage).
- No ML libraries are used. Deterministic arithmetic only.

---

**7. UI / UX & Design System (Concrete tokens)**
- Colors (from `lib/core/theme/liora_theme.dart`):
  - Background: `#FFF6F9`
  - Primary Pink: `#FDE2EA`
  - Accent Rose: `#F7B2C4`
  - Period day: `#FFB5C2`
  - Predicted period: `#FFCDD2`
  - Fertile window: `#E8D5F2`
  - Ovulation day: `#D4B5FF`
  - Text primary: `#2E2E2E`
- Spacing, shadows, radii: constants exist in `liora_theme.dart` (e.g., `LioraSpacing`, `LioraRadius`, `LioraShadows`). Use consistent spacing tokens (sm, md, lg, xl).
- Typography: Google Fonts used (Poppins/Raleway or configured fonts). Headings, body, and labels use consistent font sizes and weights defined in theme.
- Animations: subtle animations with durations used across the app:
  - Splash animation: 2000ms fade + scale
  - Onboarding sheet: 600ms slide + fade
  - Screen transitions: 400–800ms fade
  - Calendar page transitions: 300ms easeInOut
- Elevation & roundedness: containers use 16–24dp radii for major cards.

---

**8. Authentication & Error Feedback (Behavioral spec)**
- Auth uses FirebaseAuth; UI surfaces errors with `AuthProvider` friendly messages.
- Validation occurs client-side before contacting server:
  - Email format validated via regex.
  - Password: minimum length 6; additional optional rules (lower/upper/numeric) enforced by `validatePassword`.
- Exact mapping of Firebase errors to user messages exists in `auth_provider.dart` (e.g., `user-not-found`, `wrong-password`, `weak-password`, `network-request-failed`).
- Signup flow updates displayName and triggers non-health profile sync via `FirebaseSyncService`.

---

**9. Notifications (Platform policy)**
- Mobile: scheduled local notifications for period reminders, daily wellness nudges and log reminders.
- Web: notifications disabled by default — code uses `kIsWeb` to short-circuit and avoid platform-specific APIs.

---

**10. Tests & Quality Assurance**
- Unit tests:
  - `prediction_engine_test.dart` — test rolling average, next period calculation, edge cases (insufficient data).
  - `storage_service_test.dart` — test read/write and encryption round-trip using test Hive boxes.
- Widget tests:
  - `signup_widget_test.dart` — validate validators render errors and show friendly messages.
  - `calendar_widget_test.dart` — verify color rendering for different DayTypes.
- Integration tests:
  - Auth+Storage: validate signup, sign-in, and local profile sync (only with a test Firebase project or emulator).
- Commands:
  - Run unit & widget tests: `flutter test`
  - Run integration (Flutter integration tests): `flutter test integration_test` or `flutter drive --driver=...` depending on setup.

CI recommendations:
- Use `github-actions` with Flutter SDK setup, run `flutter analyze`, `flutter test`, and `flutter build apk` (optional) on `main` and PRs.

---

**11. Run & Setup Instructions (developer)**
1. Install Flutter (recommended stable channel with matching SDK).
2. Ensure `flutterfire` CLI or manual Firebase config is available.
3. Set `android/app/google-services.json` (already present if provided) and replace web keys in `lib/firebase_options.dart` with real values from console.

Commands:
```bash
# Install deps
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Android device/emulator
flutter run -d <device-id>

# Run tests
flutter test
```

Notes about Firebase keys: For full auth flows you must ensure valid `apiKey` and `appId` are in `lib/firebase_options.dart` for web, and `google-services.json` for Android. Sender ID is the Firebase project number `105498158234`.

---

**12. Update Diary / Change Log (living)**
This section is the authoritative diary for changes. Always add an entry when code or configuration is updated.

- 2026-02-09 — Initial SRS document created and added to repo (this file).
  - Removed `cloud_firestore` dependency to enforce privacy SRS.
  - Upgraded Firebase core/auth to compatible versions for web support.
  - Added web `FirebaseOptions.web` config placeholder to `lib/firebase_options.dart`.
  - Rewrote `notification_service.dart` to be web-safe; added clear `kIsWeb` short-circuits.
  - Added `firebase_sync_service.dart` to manage non-health profile sync to Firebase (explicit privacy checks).
  - Improved `auth_provider.dart`: added input validation, more specific Firebase error mapping, and automatic profile sync on signup.
  - Fixed signup and login screens to use provider-side validators and show clear errors.
  - Validated project runs on Chrome (dev run successful).

**How to add a new diary entry:**
- Add a dated subsection like above. Include files changed, short rationale, and the commit hash (if available).
- Example template:
  - `YYYY-MM-DD — Short description`
    - Files changed: `path/to/file1`, `path/to/file2`
    - Reason: <why>
    - Notes: <testing/verification steps>

---

**13. Reproducibility Checklist (for AI or engineer reproducing project)**
1. Clone repository
2. Ensure Flutter SDK installed (version compatible with project's sdk constraints in `pubspec.yaml`)
3. Make sure Android SDK / emulators available
4. Place `google-services.json` in `android/app` (if not present)
5. Replace web values in `lib/firebase_options.dart` with valid `apiKey` and `appId` from Firebase console for project `liora-43381` (or configure a test Firebase project)
6. Run `flutter pub get`
7. Run `flutter run -d chrome` to verify the web build, or `flutter run -d <android>` for android
8. Run `flutter test` for unit/widget tests

---

**14. Security & Privacy Compliance Checklist**
- All period/cycle/symptom/prediction data stored only locally (Hive) — ✅
- Local encryption key stored in `flutter_secure_storage` (Android encrypted preferences) — ✅
- No Firestore writes for health data — Firestore removed — ✅
- Firebase used only for auth — ✅

---

**15. Next Steps & Recommendations**
- Add automated unit tests covering `PredictionEngine` and `StorageService` (if not present).
- Add a small integration test using the Firebase emulator for Auth flows to validate signup/signin without touching production.
- Add GitHub Actions CI that runs `flutter analyze` and `flutter test` on PRs.
- Create a secure mechanism (CI secrets or env) to inject real Firebase web keys into `lib/firebase_options.dart` for CI builds rather than checking secrets into the repo.
- If you want cross-device settings sync (non-health), implement Realtime Database writes under `/users/{uid}/settings` with user's consent.

---

**16. File-by-file TODO suggestions (non-blocking, optional improvements)**
- `lib/firebase_options.dart` — Replace placeholder API keys with real ones and document the command used to create them.
- `lib/core/services/notification_service.dart` — Add platform-specific code in `android/` & `ios/` branches to register proper notification channels and permissions.
- `lib/core/services/firebase_sync_service.dart` — Implement actual writing to Realtime Database under `/users/{uid}` for permitted non-health preferences.
- Add `integration_test/` folder with end-to-end tests that use the Firebase emulator set.

---

If you want, I can now:
- Commit this `SRS.md` to a branch and open a PR draft.
- Create the recommended unit tests (`prediction_engine_test.dart`, `storage_service_test.dart`) and run them.
- Add a basic GitHub Actions CI workflow that runs `flutter analyze` and `flutter test` on PRs.

---

*End of SRS (2026-02-09)*
