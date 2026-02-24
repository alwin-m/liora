**Security Overview**

- **Project:** Liora (Flutter mobile app)
- **Path:** repository root
- **Scope:** this document summarizes the security posture of the codebase, highlights project-specific issues found during analysis, and gives prioritized mitigations and operational recommendations developers and maintainers should follow.

**High-level summary**

- The project is a Flutter mobile app using Firebase services (Auth, Firestore, Storage), local storage (SharedPreferences), and several third-party packages. It handles sensitive user data (menstrual cycle and related health data) which requires careful privacy and security controls.
- A short review of the repository uncovered the following high-priority items that require attention:
  - Sensitive configuration values (Firebase `google-services.json` containing API keys and project identifiers) found in the repository history and working tree. This was previously involved in a merge conflict.
  - Use of unencrypted local storage (`SharedPreferences`) for health-related data and base64-encoded profile images.
  - Notification permission and scheduling code introduced (`flutter_local_notifications`) — requires handling Android notification permission (POST_NOTIFICATIONS) and enabling secure scheduling.
  - Build configuration changes (Java desugaring enabled) were required to support dependencies and have been applied.

**Security Goals**

- Protect user privacy and sensitive health data at rest and in transit.
- Prevent accidental credential leakage in the repository or CI artifacts.
- Ensure robust authentication and least-privilege access to backend services.
- Maintain secure build and release processes (keystore, signing, CI secrets).
- Keep third-party dependencies up-to-date and monitor for vulnerabilities.

**Threat Model (brief)**

- Threat actors: opportunistic attackers, malicious insiders, compromised CI, supply-chain attacks via dependencies.
- Assets: user health data (cycle history), profile images, authentication tokens, Firestore/Storage data, app signing keys, API keys in config files.
- Attack vectors: leaked repo secrets, insecure local storage, misconfigured Firebase rules, vulnerable dependencies, insecure push notifications or intents.

**Findings & Immediate Actions (Prioritized)
1 — Remove secrets from repository
  - Problem: `android/app/google-services.json` and `android/app/**` contained firebase API keys and project identifiers and had merge conflict markers. Committed credentials risk exposure.
  - Action: Remove `google-services.json` from the repository and add to `.gitignore`.
  - Action: Use CI secrets/environment variables or runtime configuration to inject Firebase config at build time. See Firebase docs for dynamic configuration or store a sanitized JSON without credentials and inject the real values via CI.
  - Action: Rotate any keys that were exposed (create new API keys and rotate Firebase project keys). Treat the old keys as compromised until rotated.

2 — Protect health & personal data stored locally
  - Problem: Cycle data and profile images are stored using `SharedPreferences` and base64 encoding. `SharedPreferences` is not suitable for sensitive PII/medical data.
  - Action: Migrate sensitive items (cycle history, cycle parameters, local profile image) to an encrypted store such as `flutter_secure_storage` (which uses Android Keystore / iOS Keychain) or an encrypted local database (e.g., SQLCipher, sembast + encryption). Document data schema and migration steps.
  - Action: Limit what is stored locally — remove unnecessary personally-identifiable attributes and avoid storing authentication tokens in plain prefs.
  - Action: Add a privacy notice and explicit user consent screen for storing health data locally; make it easy for users to export/delete their local data.

3 — Harden Firebase Security Rules
  - Problem: Project uses Firestore and Storage; ensure rules restrict access appropriately.
  - Action: Implement strict Firestore security rules with per-user document access patterns and require `request.auth.uid` checks. Example: store user-specific cycle data under `/users/{uid}/cycleData` and require equality checks.
  - Action: Storage rules should prevent public read/write; limit object access to authenticated and authorized users only.
  - Action: Apply test coverage for rules via the Firebase emulator and CI to validate changes before deployment.

4 — Secrets Management, CI, and Signing
  - Problem: Keystore and signing config should never be committed.
  - Action: Store Android keystore files and release signing credentials in secure secret storage (GitHub Secrets, Google Cloud Secret Manager, or other vault). Configure CI to sign the app at release using secrets injected at build time.
  - Action: Add GitHub branch protection, require PR reviews, and enable secret scanning & Dependabot alerts.

5 — Notifications and Permissions
  - Problem: App requests notification permission via `flutter_local_notifications`. On Android 13+ the `POST_NOTIFICATIONS` permission is required (added). Be explicit to users about notifications and allow opt-in/opt-out.
  - Action: Request permission only when the user enables reminders. Document why permission is required. Respect Android/iOS UX guidelines for permission prompts.
  - Action: Validate scheduled notifications and ensure they don't leak sensitive data in notification content nor include PII. Notifications should be generic (e.g., "Your period may start in 3 days") and not show detailed health metrics on lock screen without consent.

6 — Dependency & Supply-chain Management
  - Action: Enable automated dependency updates (Dependabot) and run regular `flutter pub outdated` checks.
  - Action: Integrate SCA tooling (e.g., GitHub's Dependabot, Snyk) into CI to detect flagged CVEs in transitive dependencies.

7 — Static Analysis, Linting & Safe Coding
  - Action: Continue enforcing `flutter analyze` and the project's lint rules. Address `use_build_context_synchronously` warnings (avoid using BuildContext after async gaps without guarding by `if (!mounted) return;` and using pattern recommended by Flutter docs).
  - Action: Avoid `print` in production code; replace with structured logging behind a feature flag.

8 — Logging, Telemetry & Crash Reports
  - Action: If crash reporting or analytics are added, ensure explicit user consent and minimize PII in logs. Use sampling and retention policies. Securely transmit telemetry over TLS only.

9 — Secure Release & Obfuscation
  - Action: Use ProGuard/R8 obfuscation for release builds to make reverse-engineering harder (configure `gradle.properties` and Android build rules).
  - Action: Enable code signing, and keep keys secure. Use Play App Signing for Google Play if possible.

10 — Documentation & Incident Response
  - Action: Document security runbook: how to rotate keys, revoke compromised credentials, notify users, and restore services.
  - Action: Maintain `SECURITY.md` (this file) and include a vulnerability disclosure/contact method (e.g., security@your-org.example) and expected response SLA.

**Secure-By-Default Recommendations (short checklist)**

- [ ] Remove all secrets from git history (use git-filter-repo or BFG) and rotate credentials.
- [ ] Add `google-services.json` to `.gitignore`. Inject at CI/runtime instead.
- [ ] Move sensitive local data to encrypted storage (`flutter_secure_storage` or encrypted DB).
- [ ] Harden Firestore & Storage rules and test via emulator in CI.
- [ ] Use GitHub secret storage for keystore and CI signing.
- [ ] Enable Dependabot/Snyk and add automated dependency scanning to CI.
- [ ] Add pre-commit hooks to scan for accidental secrets (git-secrets, pre-commit) and enforce formatting/linting.
- [ ] Add a privacy consent flow that covers storing health data and receiving reminders.

**Example Firestore rule (starter)**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User private data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Public read-only data (if any) – be explicit
    match /public/{doc} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

**Privacy considerations**

- Health data (menstrual cycle data, flow, ovulation) should be treated as sensitive data. Limit data retention, allow user data export/deletion, and provide clear in-app information for users on what is stored and why.
- When scheduling notifications, do not include explicit health details in the notification body unless users have explicitly opted into that level of detail.

**Operational guidance**

- Establish a release checklist that includes: dependency scan results, updated security rules, secret rotation as required, and QA signoff that sensitive data is stored encrypted.
- Maintain a private key/keystore rotation schedule and store keys in a vault.

**Contact & Disclosure**

If you discover a security vulnerability in this project, please:

- Create an issue in the private/security tracker or email: security@<your-org-domain> (replace with the project's responsible security contact).
- Provide reproducible steps, affected versions, and a suggested remediation if possible.

---

This `SECURITY.md` is curated for the current codebase (Firebase-backed Flutter app that stores local health data). The next steps are: remove secrets from the repo, migrate sensitive local storage to encrypted storage, add Firestore/Storage rules, and bake secrets into CI for release signing. Follow the checklist above and incorporate CI checks (Dependabot, SCA, pre-commit secret scanning) as early automation.
# Security Policy

## Supported Versions

The following versions of this project are currently supported with security updates:

| Version                | Supported |
| ---------------------- | --------- |
| Latest stable release  | ✅         |
| Previous minor release | ✅         |
| Older releases         | ❌         |

> Users are encouraged to upgrade to the latest version to ensure maximum security and stability.

---

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Contact Email:** [alwinmadhu4060@gmail.com](mailto:alwinmadhu4060@gmail.com)
**Subject:** Security Vulnerability Report

Please include the following details when reporting:

* A clear description of the vulnerability
* Steps to reproduce the issue (if applicable)
* The potential impact of the vulnerability
* Any relevant screenshots, logs, or proof of concept

---

## Response Timeline

We aim to respond to security reports promptly:

* **Initial response:** within 48–72 hours
* **Evaluation & validation:** within 5–7 days
* **Fix & mitigation:** as soon as reasonably possible, depending on severity

---

## Responsible Disclosure

To protect users and the project, we request that reporters:

* Do not publicly disclose vulnerabilities before a fix is released
* Avoid exploiting the issue beyond necessary demonstration
* Allow reasonable time for investigation and resolution

---

## Security Practices

This project follows standard security best practices, including:

* Regular dependency and framework updates
* Secure handling of user data
* Restricted access to sensitive configuration
* Ongoing review of critical components

---

## Acknowledgements

We thank the security community and contributors who help identify and responsibly disclose security issues, improving the safety and reliability of this project.
