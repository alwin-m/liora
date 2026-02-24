# Project Unit Testing & System Audit Report (Automated Static Review)

> Generated: 2026-02-24

## Project Overview

- Name: lioraa
- Platform: Flutter (multi-platform)
- Scope of review: static code inspection across repository, key file collection and analysis of Firebase, Android, local storage, and service modules. This is a static audit (no runtime execution). Some dynamic checks (unit test runs, integration test runs, emulated devices) were not executed in this pass.

## High-level summary

- Critical issues found: 3
  - Merge conflicts present in `firebase.json` and `android/app/google-services.json` (build-blocking).
  - Sensitive health data is stored locally with an incorrect assumption that `SharedPreferences` is encrypted by default — this is a privacy/security risk.
  - No Firestore security rules were found in the repository; `firebase.json` contains conflicts. This leaves backend rules unverified.
- Major issues: several (hardcoded Firebase API keys in `lib/firebase_options.dart` and `android/app/google-services.json`; unsafe null assumptions in services using `FirebaseAuth.instance.currentUser!.uid`).
- Minor issues: code style, missing explicit `INTERNET` permission in `AndroidManifest.xml`, potential type-safety with Firestore fields.


---

## File-by-File Audit Report (selected key files)

Note: The repository contains many files. This report lists the files analyzed in detail and highlights findings. For full 100% file-by-file coverage, a follow-up automated run can be executed to enumerate every source file and produce a per-file checklist.

- `pubspec.yaml`
  - Reviewed dependencies: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `shared_preferences`, `provider`, etc. Versions are compatible with Dart SDK ^3.8.1.
  - No direct issues, but upgrade/migration guidance may be required for latest SDKs.

- `lib/firebase_options.dart`
  - Contains Firebase client configuration and API keys (web/apiKey, android/apiKey, ios/apiKey).
  - Finding: API keys and App IDs are checked into repository. While Firebase client API keys are not full secrets, presence of app IDs and API keys in repo increases attack surface and should be rotated and/or kept out of source where possible (use CI secrets or environment injection).

- `firebase.json` and `android/app/google-services.json`
  - Both files contain unresolved Git merge conflict markers (<<<<<<<, =======, >>>>>>>). This will break JSON parsing and tooling (FlutterFire CLI, Gradle plugin) and prevents correct initialization for Firebase.
  - Severity: Critical — must be resolved before any Firebase-dependent operations or builds.

- `lib/services/auth_service.dart`
  - Correct use of Firebase Authentication SDK and Firestore for user metadata.
  - Privacy guard checks exist to block medical fields from being written via `updateUserProfile()` — good practice.
  - Exception handling: methods rethrow FirebaseAuthException; acceptable. Consider mapping errors to user-friendly error codes.

- `lib/services/local_medical_data_service.dart`
  - Stores sensitive medical/health data using `SharedPreferences` and JSON encoding.
  - Comments claim platform-native encryption via SharedPreferences/Keychain. This is incorrect: `SharedPreferences` is NOT encrypted by default on Android; you must use `EncryptedSharedPreferences` (AndroidX) or `flutter_secure_storage`/`encrypted_shared_preferences` Flutter plugin. The current implementation therefore stores sensitive medical data in plaintext on disk.
  - Severity: Critical (privacy & regulatory risk — PHI exposure).
  - Recommendation: Migrate to `flutter_secure_storage` or platform-specific encrypted storage; implement optional user passphrase or device security checks.

- `lib/services/cycle_provider.dart` and `lib/services/cart_provider.dart`
  - Both persist JSON to `SharedPreferences`. For `cart_provider`, this is acceptable for non-sensitive shopping-cart data, but make sure expiry and size limits are enforced.
  - `cycle_provider` stores health data via `SharedPreferences` — critical issue (see above).

- `lib/services/product_service.dart` and `order_service.dart`
  - Use `FirebaseFirestore` with transactions — transaction-based stock updates and order creation are implemented, which is good for consistency.
  - Unsafe assumptions: code uses `_auth.currentUser!.uid` (forced unwrap) without null checks in `OrderService`. If called without a logged-in user, this will throw a runtime exception. Use nullable checks and surface clear errors.
  - Accessing snapshot fields like `snapshot['stock']` is brittle if schema changes or field missing — prefer `snapshot.get('stock')` and null/type checks.
  - Severity: Major (runtime exceptions, potential data corruption if assumptions fail).

- `lib/main.dart`
  - Initializes Firebase with `DefaultFirebaseOptions.currentPlatform` — depends on `firebase_options.dart` and `google-services.json` being correct.
  - Providers and routes are correctly wired. No critical issues here.

- `android/app/src/main/AndroidManifest.xml`
  - No explicit `<uses-permission android:name="android.permission.INTERNET"/>` entry was found. Typically Flutter apps add it automatically in the generated manifest merging, but I recommend explicitly ensuring `INTERNET` permission is present to avoid runtime network failures on some targets.
  - `applicationId` in Gradle is `com.example.lioraa` — must be set to production reverse-DNS when publishing.

- Tests (`test/`)
  - `privacy_tests.dart` and `widget_test.dart` exist. They were not executed in this static pass. Recommend running `flutter test` and adding CI automation.


---

## Function-Level Testing Report (selected call sites)

- `AuthService.registerUser` and `loginUser`
  - Proper try/catch; FirebaseAuthException rethrown. Consider returning typed error objects or codes.
  - Input validation: email/password trimmed, but no format/strength checks — add validation.

- `OrderService.placeOrder` & `cancelOrder`
  - Transactional approach is correct for stock update + order creation.
  - Risk: `final uid = _auth.currentUser!.uid;` — forced non-null; add guard with user presence validation.
  - Risk: `productSnap['stock']` untyped — add type checks and cast to `int`.

- `ProductService.reduceStock` / `restoreStock`
  - Use transactions; `currentStock` variable not type-checked — add int parsing.
  - `reduceStock` throws a generic `Exception('Out of stock')` — consider domain-specific exceptions.

- `LocalMedicalDataService` methods
  - `getMedicalData`, `saveMedicalData`, `deleteMedicalData` — API returns booleans or maps. Add clear error codes for callers and confirm encryption at storage layer.
  - `verifyLocalOnlyCompliance()` attempts to guarantee local-only storage. This cannot be reliably asserted by local code alone — server-side rules and code reviews are required. Also it trusts `SharedPreferences` encryption which is false.


---

## Database Interaction Report

- Firestore collections used:
  - `users/{uid}` — stores user metadata (email, name, profileCompleted, role, createdAt)
  - `products/*` — product catalog, `stock` field mutated in transactions
  - `users/{uid}/orders/*` — order documents created in transactions

- Data sent to backend (explicit):
  - `AuthService.registerUser` writes `email`, `name`, `createdAt`, `role`, `profileCompleted`.
  - `OrderService.placeOrder` writes order documents into `users/{uid}/orders/`.
  - `ProductService` updates `stock` in `products` collection.

- Data that must never be sent (policy enforced in code): Medical/cycle data is explicitly forbidden from being stored in Firestore; code contains checks and comments to that effect.

- Missing items:
  - No Firestore security rules in repository — cannot confirm access control. Without properly configured rules (or if rules are overly permissive), user data could be exposed.
  - No server-side validation for order writes beyond transaction-level stock checks. Consider adding Cloud Functions or server-side validation for payment status, order authenticity.

- Efficiency:
  - Use of transactions for stock/order is correct for consistency but consider sharding or counters if scaling to high traffic.


---

## Local Storage Audit

- Sensitive data stored locally:
  - Medical/cycle data (`LocalMedicalDataService.medicalDataKey`) — currently stored in `SharedPreferences` as JSON. This is NOT secure.
  - Cart items stored as JSON in `SharedPreferences` (`cart_items`) — acceptable for non-sensitive data.

- Recommendations:
  - Migrate medical data storage to `flutter_secure_storage` or `encrypted_shared_preferences` and enable device-backed key protection (KeyStore/Keychain).
  - Implement storage size limits and rotation for local history data, and consider optional user-controlled cloud backup (explicit opt-in with encryption if needed).


---

## Security Risk Assessment

- Critical
  - Git merge conflicts in `firebase.json` and `google-services.json` — prevents Firebase initialization and indicates unsafe repository state.
  - Medical data stored insecurely using `SharedPreferences` (not encrypted) — major privacy/regulatory non-compliance risk.
  - No Firestore security rules found in repo — cannot verify access controls.

- Major
  - Hard-coded Firebase API keys and app IDs in `lib/firebase_options.dart` and `google-services.json`.
  - Forced unwraps of `currentUser` (`currentUser!.uid`) leading to runtime exceptions and potential broken flows.
  - Use of plain `SharedPreferences` where encryption is required.

- Minor
  - Potential missing `INTERNET` permission in `AndroidManifest.xml` (verify final merged manifest).
  - Use of untyped Firestore field access (e.g., `snapshot['stock']`) — brittle to schema changes.


---

## Performance Analysis

- Heavy operations: None obvious on main thread in services. However:
  - Repeated synchronous JSON encode/decode and SharedPreferences access on UI startup may cause jank if data is large — ensure these run off the UI thread or use proper async flows.
  - `CycleProvider` constructs demo history entries on first load — small but be cautious with large histories.

- Potential unnecessary rebuilds:
  - Providers call `notifyListeners()` appropriately; ensure listeners are scoped to minimize UI rebuilds.

- Network/API optimization:
  - Firestore streaming `ProductService.getProducts()` returns full product documents; consider pagination or reduced projections for large catalogs.


---

## Android APK Readiness Report

- Build file (`android/app/build.gradle.kts`) uses defaults from Flutter; compileSdk/targetSdk pulled from Flutter tooling.
- Critical blockers:
  - Merge conflicts in `google-services.json` and `firebase.json` must be resolved for Firebase-gradle plugin to operate.
  - Verify `applicationId` value for production; currently `com.example.lioraa`.
- Signing: release signing uses debug signing by default in code comments — must configure proper signing keys for Play Store.


---

## Detected Errors & Bugs (by severity)

- Critical
  1. `firebase.json` and `android/app/google-services.json` contain unresolved Git merge conflicts — break build/initialization.
  2. Medical data stored in `SharedPreferences` without encryption — privacy/regulatory violation.
  3. No Firestore security rules present in repository; cannot verify permissions.

- Major
  1. Hard-coded Firebase API keys and app IDs in `lib/firebase_options.dart` and `google-services.json`.
  2. Forced `currentUser!` unwraps in `OrderService` and elsewhere — runtime crash risk when user not authenticated.
  3. Unchecked Firestore field access (e.g., `snapshot['stock']`) — runtime exception risk.

- Minor
  1. Missing explicit `INTERNET` permission in `AndroidManifest.xml` (verify merged manifest).
  2. Some comments claim encryption where not present — documentation mismatch.


---

## Architectural Drawbacks

- Health-critical data stored on device but using an insecure mechanism reduces trust and can violate regulations (GDPR/HIPAA depending on jurisdiction).
- Lack of server-side validation or Cloud Functions for critical flows (orders, refunds) increases risk of fraud or inconsistent state.
- All sensitive logic executed on-device means single-device availability; if multi-device sync is later desired a secure encrypted sync would be required.


---

## Improvement Plan (Prioritized)

1. Resolve merge conflicts immediately for `firebase.json` and `android/app/google-services.json` (critical).
2. Replace `SharedPreferences` storage for medical data with `flutter_secure_storage` or a vetted encrypted storage library and migrate existing data securely; add migration script.
3. Remove or rotate API keys if leaked; move credentials to CI/CD or runtime environment where possible.
4. Add Firestore security rules to the repository and test them locally using `firebase emulators` and `firebase rules:test`.
5. Hardening: add null checks for `_auth.currentUser` before usage; add typed field access for Firestore reads.
6. Add automated tests and CI: run `flutter analyze`, `flutter test`, and `flutter build apk` in CI to catch issues early.
7. Add a security checklist in CI to scan for merge markers, secrets, and plaintext sensitive data.


---

## Final Verdict

- Current state: NOT production-ready.
- Primary blockers: unresolved merge conflicts for Firebase configuration, insecure local storage of sensitive health data, and lack of verified Firestore security rules.
- With the prioritized fixes above (esp. encryption migration and resolving merge conflicts), the project can be made production-ready pending further testing (unit, integration, and security rule tests).


---

## Next Steps I can take (choose any)

- Automatically fix or remove merge markers in `firebase.json` and `android/app/google-services.json` if you confirm which branch/version to keep.
- Implement migration to `flutter_secure_storage` for medical data and update callers.
- Add CI workflow to run `flutter analyze` and `flutter test` and to detect merge markers/secrets.
- Run `flutter test` locally and add failing tests to the report.


---

Appendix: Files scanned in detail:
- pubspec.yaml
- firebase.json
- android/app/google-services.json
- android/app/src/main/AndroidManifest.xml
- android/app/build.gradle.kts
- lib/firebase_options.dart
- lib/main.dart
- lib/services/*.dart (auth_service, product_service, order_service, cart_provider, cycle_provider, local_medical_data_service)
- test/*


(End of automated static audit)
