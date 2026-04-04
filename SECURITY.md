# Liora Security Policy & Architecture

**Version:** 3.0 | **Last Updated:** April 4, 2026 | **Status:** Production (Adaptive AI Update)

> Liora is a **privacy-first** women's wellness application with **zero-transmission health data architecture**. All menstrual cycle predictions and health information remain exclusively on the user's device.

---

## 📋 Table of Contents

1. [Supported Versions](#supported-versions)
2. [Security Architecture](#security-architecture)
3. [Data Protection Layers](#data-protection-layers)
4. [Vulnerability Reporting](#vulnerability-reporting)
5. [Implementation Standards](#implementation-standards)
6. [Dependency Security](#dependency-security)

---

## Supported Versions

| Version | Status | Support Level |
|---------|--------|---------------|
| 3.19.x (Flutter) + 3.3.x (Dart) | ✅ Current | Full Security Updates |
| 3.18.x | ⚠️ Legacy | Critical Fixes Only |
| < 3.18.x | ❌ EOL | No Support |

---

## Security Architecture

### 🏗️ Data Isolation Strategy

Liora implements **strict data layer separation** preventing health information from ever reaching backend systems. E-commerce features have been decommissioned in this branch to maximize the focus on health security:

```
Layer 1: AUTHENTICATION (Backend Storage)
├── Firebase Authentication (Email/Password)
├── User profile (Name, Role, Metadata)
└── Storage: HTTPS encrypted, server-side backup

Layer 2: ADAPTIVE HEALTH DATA & AI (Device-Only Storage)
├── Cycle tracking (periods, predictions, phases)
├── Annie Hathaway Algorithm (Training weights, Recency bias)
├── Daily Flow Logs (Percentage, Pain metrics)
├── Health symptoms and metrics
└── Storage: SharedPreferences + Platform encryption

Layer 3: SESSION & SECURITY (Runtime Only)
├── Biometric tokens (Face/Fingerprint)
├── Session security service
└── In-memory, never persisted
```

### 🔐 Encryption Strategy

| Data Type | Storage Location | Encryption | Method |
|-----------|-----------------|-----------|--------|
| **Credentials** | Firebase Auth | Server-side SHA256 + Bcrypt | Firebase-managed |
| **Profile Data** | Cloud Firestore | TLS in-transit + at-rest | AES-256 server-side |
| **AI/Medical Data**| SharedPreferences | Platform-native encryption | iOS Keychain / Android Keystore |
| **API Keys** | Secure Storage | AES-256 encrypted | `flutter_secure_storage` |
| **Biometric Data** | Device TEE | Hardware-backed encryption | OS-level (no app access) |

---

## Data Protection Layers

### 🚫 MEDICAL DATA (Never Leaves Device)

```dart
// ✅ PROTECTED FIELDS (Device-Only)
lastPeriodStartDate          // Never transmitted
averageCycleLength           // Never transmitted
averagePeriodDuration        // Never transmitted
cyclePhaseInfo               // Computed locally only
ovulationPredictions         // On-device ML model
symptomTracking              // Local storage only
bleedingPatterns             // Local analysis only
```

**Implementation:**
- Stored via `SharedPreferences` with platform-native encryption
- Accessed only through `LocalMedicalDataService`
- Cleared automatically on app uninstall
- Never included in Firebase Firestore queries

// ✅ ALLOWED FIELDS (Secure Backend Storage)
email                        // Encrypted in transit
name                         // AES-256 at rest
role (admin/user)           // Access-controlled
createdAt timestamp         // Server-managed
profileCompleted status     // Progress tracking
sessionTokens               // Firebase-managed, short-lived

**Implementation:**
- Firebase Authentication handles password hashing
- User documents in Firestore contain NO medical or AI training fields
- All backend requests use HTTPS/TLS
- Database rules restrict access to own user document

### 🤖 ANNIE HATHAWAY AI (LOCAL TRAINING ONLY)

Annie Hathaway is a self-learning algorithm that improves based on logged data.

| Data Type | Mitigation |
|-----------|------------|
| **Flow Percentages** | Local-only analysis (Recency-weighted) |
| **Pain Intensity** | Stored in history, never transmitted |
| **Algorithm Weights** | Recomputed locally each session |
| **Learning Phase** | Zero cloud dependency (works offline) |

---

## Vulnerability Reporting

### 🚨 Security Issue Disclosure

If you discover a vulnerability in Liora:

**Report To:** [alwinmadhu4060@gmail.com](mailto:alwinmadhu4060@gmail.com)  
**Subject Line:** `[SECURITY] Liora Vulnerability`

### Required Information

```
1. Vulnerability Type (e.g., data leak, authentication bypass)
2. Affected Component(s) (e.g., auth_service.dart, cycle_provider.dart)
3. Reproduction Steps (detailed, if applicable)
4. Potential Impact:
   - Data exposure scope (medical data? commerce data? both?)
   - Affected user population (all users? authenticated only?)
   - System access level required (none? admin? device root?)
5. Proof of Concept (code/screenshots, if safe to share)
```

### Response Timeline

| Stage | Timeline | Action |
|-------|----------|--------|
| **Initial Contact** | 24–48 hours | Confirm receipt, assign investigator |
| **Verification** | 5–7 days | Validate report, assess severity |
| **Development** | 7–30 days | Create fix, test in staging |
| **Release** | On availability | Deploy patch, notify users |
| **Public Disclosure** | After release | Publish advisory with credit |

### Severity Tiers

| Severity | Examples | Timeline |
|----------|----------|----------|
| **Critical** 🔴 | Medical data transmission, auth bypass, root access | 24-48 hours |
| **High** 🟠 | Single-user data exposure, session hijacking | 3-5 days |
| **Medium** 🟡 | XSS in UI, weak password policy | 7-10 days |
| **Low** 🔵 | UI bugs, documentation errors | 30 days or next release |

### Responsible Disclosure Agreement

Reporters agree to:

- ✅ Allow reasonable time for fixing before public disclosure
- ✅ Not exploit vulnerabilities beyond necessary proof-of-concept
- ✅ Not access user data beyond minimum required for reproduction
- ✅ Work confidentially with the security team

In return, we:

- ✅ Investigate promptly and professionally
- ✅ Keep reporter informed of progress
- ✅ Credit reporter in security advisory (unless requested anonymously)
- ✅ Avoid legal action for good-faith security research

---

## Implementation Standards

### Dependencies & Version Pinning

**Critical Security Packages:**

```yaml
# PINNED VERSIONS (Security-Critical)
firebase_core: ^4.4.0         # Auth & DB encryption
firebase_auth: ^6.1.3          # Password hashing
flutter_secure_storage: ^9.2.4 # Encryption at rest
local_auth: ^2.3.0             # Biometric auth
crypto: ^3.0.6                 # SHA256/AES utilities

# MONITORED PACKAGES (Quarterly Reviews)
provider: ^6.0.0               # State management
http: ^1.1.0                   # HTTPS client
firebase_storage: ^11.0.0      # Media storage
shared_preferences: ^2.2.2     # Local persistence
```

**Monthly Dependency Audit:**
```bash
flutter pub outdated          # Check for updates
flutter pub get               # Install dependencies
flutter analyze               # Lint check
flutter test                  # Unit test suite
```

### Code-Level Security Checks

**File Review Checklist:**

- [ ] No hardcoded API keys or credentials
- [ ] No `print()` statements logging sensitive data
- [ ] All medical fields have `[PRIVACY]` comment tag
- [ ] No medical data in Firestore queries
- [ ] `LocalMedicalDataService` used exclusively for health data
- [ ] OAuth tokens stored in `flutter_secure_storage` only
- [ ] All network requests use HTTPS/TLS
- [ ] Error messages don't leak system paths or versions

### Biometric Authentication

**Implementation (iOS & Android):**

```dart
// ✅ Uses platform-native secure enclave
final auth = LocalAuthentication();
final isAuthenticated = await auth.authenticate(
  localizedReason: 'Unlock your profile',
  options: const AuthenticationOptions(
    stickyAuth: true,        // Session persists until timeout
    biometricOnly: false,    // Allow PIN as fallback
  ),
);
```

**Security Properties:**
- Biometric data never leaves device TEE
- App never sees raw biometric input
- 5-minute session timeout
- Lockout after 5 failed attempts

### Session Security

**Session Timeout Configuration:**

```dart
// lib/core/session_security_service.dart
static const sessionTimeout = Duration(minutes: 15);
static const biometricSessionTimeout = Duration(minutes: 5);

// Automatic logout on timeout
void _startSessionTimer() {
  _sessionTimer = Timer(sessionTimeout, () {
    clearSecureData();
    redirectToLogin();
  });
}
```

---

## Dependency Security

### Third-Party Risk Assessment

| Package | Purpose | Security Review | Status |
|---------|---------|-----------------|--------|
| **firebase_core** | Backend auth & DB | ✅ Google-maintained | Trusted |
| **provider** | State management | ✅ Remi community | Trusted |
| **flutter_secure_storage** | Encryption | ✅ Active maintainer | Trusted |
| **tflite_flutter** | ML inference | ✅ Google TF team | Trusted |
| **http** | HTTPS client | ✅ Dart team | Trusted |

### Supply Chain Security

- ✅ All packages from pub.dev (official repository)
- ✅ No path dependencies or git sources
- ✅ Pubspec.lock committed to version control
- ✅ CI/CD verifies lock file hasn't drifted
- ✅ No private/unpublished packages

---

## Threat Model & Mitigations

### Threat: Medical Data Leakage

| Threat | Scenario | Mitigation |
|--------|----------|-----------|
| Data transmission | Attacker intercepts network | All medical data local-only, never transmitted |
| Backend compromise | Hacker accesses database | No medical fields in Firestore |
| Device theft | Physical access to unlocked phone | Platform encryption + biometric lock |
| App memory dump | Attacker extracts running app memory | Medical data encrypted at rest |

### Threat: Authentication Bypass

| Threat | Scenario | Mitigation |
|--------|----------|-----------|
| Password crack | Brute-force on weak passwords | Firebase enforces 8+ chars, complexity |
| Session hijack | MitM intercepts auth token | Short-lived tokens, HTTPS-only |
| Biometric spoof | Fake fingerprint/face | Device TEE handles verification |
| Account takeover | Compromised email | Email verification required, 2FA optional |

### Threat: Code Injection

| Threat | Scenario | Mitigation |
|--------|----------|-----------|
| SQL injection | Malicious Firestore query | Firestore uses document references, not SQL |
| XSS in UI | Malicious input rendered as HTML | Flutter renders native widgets, not web HTML |
| Command injection | Shell execution via user input | No shell commands in app code |

---

## Security Acknowledgements

We thank the following for improving Liora's security:

- 🙏 **Flutter & Dart Teams** — Security frameworks and best practices
- 🙏 **Firebase** — Managed authentication and encryption
- 🙏 **Security Researchers** — Vulnerability reports and feedback
- 🙏 **Our Users** — Trusting us with sensitive health data

---

## Next Steps

### If You Find a Vulnerability

👉 **Email:** [alwinmadhu4060@gmail.com](mailto:alwinmadhu4060@gmail.com)  
👉 **Include:** Vulnerability type, reproduction steps, impact assessment

### To Review Our Implementation

- 📖 [PRIVACY_POLICY.md](PRIVACY_POLICY.md) — Data handling in detail
- 📖 [QUICKSTART_SECURITY.md](QUICKSTART_SECURITY.md) — Security setup for developers
- 📖 [SECURITY_COMPREHENSIVE.md](SECURITY_COMPREHENSIVE.md) — Deep-dive technical guide

---

**Liora: Privacy by Design. Security by Default.** 💖
