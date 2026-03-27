# Data Governance & Privacy Policy - Liora Application

## Executive Summary

Liora implements **strict data separation with zero tolerance for unauthorized medical data transmission**. All menstrual cycle and health-related information is classified as SENSITIVE HEALTH DATA and stored **exclusively on the user's local device**, while authentication and commerce data are securely managed through backend services.

---

## Data Classification Framework

### Category 1: Backend-Stored Authentication & Commerce Data

**Storage Location:** Firebase Authentication + Cloud Firestore  
**Network Transmission:** YES - Encrypted HTTPS  
**User Consent:** Required via Terms of Service  

**Allowed Fields:**

```
users/{uid}
├── email: string                    # Email address for login
├── name: string                     # Display name
├── role: string                     # Role (admin/user)
├── createdAt: timestamp             # Account creation date
├── profileCompleted: boolean        # Onboarding status
└── [NO MEDICAL FIELDS]
```

**Order Records:**
```
users/{uid}/orders/{orderId}
├── productId: string
├── productName: string
├── price: number
├── quantity: number
├── address: string
├── phone: string
└── [NO MEDICAL FIELDS]
```

---

### Category 2: Strictly Local Medical Data

**Storage Location:** Device SharedPreferences (Platform-Encrypted)  
**Network Transmission:** NEVER - Absolutely Forbidden  
**Deletion:** Automatic on app uninstall  

**Protected Fields (NEVER in backend):**

```
LOCAL STORAGE ONLY:
├── lastPeriodStartDate
├── averageCycleLength
├── averagePeriodDuration
├── Cycle history entries
├── Flow intensity level
├── Cycle regularity status
├── PMS symptom tracking
├── Any health-related onboarding responses
└── Future health tracking inputs
```

---

## Implementation Architecture

### Data Storage Layers

| Layer | Storage | Encryption | Sync | Backup |
|-------|---------|-----------|------|--------|
| **Auth/Commerce** | Firebase | TLS + Server-side | ✓ Optional | ✓ Yes |
| **Medical Data** | SharedPreferences | Platform-Native | ✗ Never | ✗ Never |
| **Session Data** | Memory | RAM-Only | N/A | ✗ Never |

---

### Network Request Policy

#### ALLOWED Backend Requests:

```dart
// Authentication
POST /auth/register
  ├── email
  ├── password (hashed)
  └── name

POST /auth/login
  ├── email
  └── password hash

// Commerce
GET /products
POST /orders
GET /orders/{uid}
```

#### FORBIDDEN Backend Requests:

```dart
// NEVER send these fields
✗ lastPeriodDate
✗ cycleLength
✗ periodLength
✗ flowLevel
✗ cycleRegularity
✗ pmsLevel
✗ Any health information
```

---

## Implementation Details

### 1. Cycle Provider (Local-Only)

**File:** `lib/services/cycle_provider.dart`

```dart
// ✓ CORRECT: Saves to local storage only
Future<void> updateCycleData({...}) async {
  _cycleData = newData;
  await _saveLocalOnly(newData);  // ← Local storage only
  // ✗ NO _saveRemote() call
}
```

**Key Features:**
- ✓ Reads from SharedPreferences only
- ✓ Saves to SharedPreferences only
- ✓ Zero Firestore sync for medical data
- ✓ Offline-capable with default fallback
- ✓ clearLocalData() method for logout

---

### 2. LocalMedicalDataService

**File:** `lib/services/local_medical_data_service.dart`

**Enforces:**
- Platform-native encryption (iOS Keychain, Android EncryptedSharedPreferences)
- Data deletion on logout/uninstall
- Compliance verification methods
- Audit logging for privacy reviews

**Public Methods:**
```dart
static Future<Map<String, dynamic>?> getMedicalData()
static Future<bool> saveMedicalData(Map<String, dynamic> data)
static Future<bool> deleteMedicalData()
static Future<bool> verifyLocalOnlyCompliance()
static Future<int> getLocalMedicalDataSize()
static Future<bool> clearAllPrivateDataOnLogout()
```

---

### 3. AuthService (Backend-Only)

**File:** `lib/services/auth_service.dart`

**Enforces:**
- Registration WITHOUT medical fields
- Explicit privacy guard preventing medical field storage
- Throws exception if medical data detected in update

```dart
Future<void> updateUserProfile({...}) async {
  // PRIVACY GUARD: Detect and reject medical fields
  if (updates.containsKey('lastPeriodDate')) {
    throw Exception('[PRIVACY VIOLATION] Medical field in backend update');
  }
}
```

---

### 4. Cycle Algorithm (Offline Computation)

**File:** `lib/home/cycle_algorithm.dart`

**Features:**
- Pure local computation (no network calls)
- Uses only device date/time + local cycle data
- Mathematically safe modulo arithmetic
- Fully offline-capable
- Returns results immediately without waiting

---

## Security Guarantees

### What Users Can Trust:

✓ **Medical data NEVER leaves their device**
- No backend database storage
- No cloud sync
- No analytics tracking
- No third-party access

✓ **Full offline functionality**
- Cycle predictions work without internet
- All period data accessible offline
- Smooth UX regardless of connectivity

✓ **Automatic deletion on uninstall**
- SharedPreferences data removed with app
- No residual medical data on device
- Clean uninstall process

✓ **Authentication security**
- Password never stored in plaintext
- Firebase handles secure password hashing
- Session tokens are short-lived

---

## Audit Requirements

### Weekly Audit Checklist

#### 1. Network Request Audit

```bash
# Verify no medical data in network calls
grep -r "lastPeriodDate\|cycleLength\|periodLength" lib/
grep -r "flowLevel\|cycleRegularity\|pmsLevel" lib/

# Should return: ZERO results
```

#### 2. Firestore Write Audit

```bash
# Verify no medical fields in Firestore upserts
grep -r "\.update({" lib/services/
grep -r "\.set({" lib/services/

# Check: No cycle-related fields
```

#### 3. SharedPreferences Audit

```bash
# Verify medical data saved locally
# Check cycle_provider.dart
# Expected: _saveLocalOnly() called, NO _saveRemote()
```

#### 4. Offline Capability Audit

```bash
# Verify cycle predictions work without network
# Test cycle_algorithm.dart standalone
# Expected: All calculations succeed without network
```

#### 5. Plugin Audit

```bash
# Verify no unauthorized data sync plugins
grep -r "cloud_sync\|firebase_cloud_messaging\|analytics" pubspec.yaml

# Expected: No auto-sync plugins for medical data
```

---

## Privacy By Design

### Data Minimization

Only collect cycle data necessary for predictions:
- ✓ Last period start date
- ✓ Average cycle length
- ✓ Average period duration
- ✗ Age, DOB, location, device ID
- ✗ Any PII beyond email

### User Control

Users can at any time:
- ✓ Edit cycle data locally
- ✓ Delete all medical data
- ✓ Log out (clears local data)
- ✓ Uninstall (auto-deletes via SharedPreferences)

### Transparency

All data is handled via:
- Platform-native encrypted storage
- Clear method names (`_saveLocalOnly`, `clearLocalData`)
- Comprehensive logging with `[PRIVACY]` prefix
- Privacy comments in code

---

## Compliance Verification

### Code Review Checklist

Before any production deployment, verify:

- [ ] `cycle_provider.dart` has NO `FirebaseFirestore` imports
- [ ] `updateCycleData()` calls ONLY `_saveLocalOnly()`
- [ ] `CycleDataModel` has NO `fromFirestore()` factory
- [ ] No medical fields in `users/` Firestore collection
- [ ] `LocalMedicalDataService` implements all documented methods
- [ ] `AuthService.updateUserProfile()` includes medical field guards
- [ ] `cycle_algorithm.dart` has NO network imports
- [ ] All new API endpoints reviewed for medical data transmission
- [ ] Medical data logging uses `[PRIVACY]` prefix only
- [ ] Unit tests verify offline cycle prediction
- [ ] Integration tests verify NO medical backend requests

---

## Incident Response

### If Medical Data Leakage Detected

1. **IMMEDIATE:** Stop the leak (rollback to LastKnownGood)
2. **ASSESSMENT:** Determine scope and duration of exposure
3. **NOTIFICATION:** Inform affected users transparently
4. **REMEDIATION:** Fix code and implement validation
5. **PREVENTION:** Add automated compliance checks to CI/CD

---

## Regulatory Compliance

### HIPAA (Health Insurance Portability and Accountability Act)

✓ **Compliant Features:**
- No PHI transmission to external systems
- Device-native encryption
- User consent via app terms
- Data deletion on user request

**Note:** Liora does not currently serve as HIPAA-covered entity but implements best practices.

### GDPR (General Data Protection Regulation)

✓ **Compliant Features:**
- Right to access (users can view local data)
- Right to delete (automatic on uninstall)
- Right to data portability (export via email?)
- Legitimate interest (private health tracking)

---

## Future Enhancements

### Potential Improvements (Maintain Privacy)

- [ ] Local end-to-end encryption for SharedPreferences
- [ ] Optional encrypted cloud backup (user-controlled, client-side)
- [ ] Privacy dashboard showing what data exists where
- [ ] Automatic privacy audit reports
- [ ] Biometric lock for sensitive health features
- [ ] Privacy-preserving analytics (differential privacy)

---

## Contact & Questions

For privacy-related questions or concerns:
- Review this document
- Check code comments (search `[PRIVACY]`)
- Review `LocalMedicalDataService` documentation
- Audit using checklist above

---

**Last Updated:** February 22, 2026  
**Policy Version:** 2.0  
**Status:** Active - Enforced in Code
