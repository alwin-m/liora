# Security & Privacy Audit Checklist - Liora

**Last Audit Date:** _________________  
**Auditor:** _________________  
**Status:** [ ] PASS [ ] FAIL [ ] NEEDS REMEDIATION  

---

## Phase 1: Code Static Analysis

### 1.1 Import Audit
- [ ] `cycle_provider.dart` contains NO Firebase imports
  - Expected: Only `shared_preferences`, `dart:convert`, `flutter`
- [ ] `cycle_data.dart` has NO Firestore imports
- [ ] `cycle_algorithm.dart` has ZERO backend imports
- [ ] `auth_service.dart` ONLY for authentication (not medical data)

**Issues Found:** ____________________

---

### 1.2 Medical Data Field Audit

**Check all files for presence of medical data fields:**

```bash
grep -r "lastPeriodDate" lib/
grep -r "cycleLength" lib/
grep -r "periodLength" lib/
grep -r "flowLevel" lib/
grep -r "cycleRegularity" lib/
grep -r "pmsLevel" lib/
```

- [ ] These fields appear ONLY in:
  - [ ] `lib/models/cycle_data.dart` (data structure)
  - [ ] `lib/services/cycle_provider.dart` (local storage)
  - [ ] `lib/home/cycle_algorithm.dart` (computation)
  - [ ] `lib/onboarding/onboarding_screen.dart` (input collection)

- [ ] These fields appear NOWHERE in:
  - [ ] Firebase write operations
  - [ ] Network request bodies
  - [ ] API endpoints
  - [ ] Analytics events
  - [ ] Crash reporting

**Issues Found:** ____________________

---

### 1.3 Firestore Write Audit

**Check for any medical field writes to Firestore:**

```dart
// Find all instances of:
db.collection('users').doc(uid).set({...})
db.collection('users').doc(uid).update({...})
FirebaseFirestore.instance.collection(...)
```

- [ ] No medical fields in user document updates
- [ ] `profileCompleted` flag is backend field (OK)
- [ ] `lastPeriodDate` does NOT appear in Firestore writes
- [ ] `cycleLength` does NOT appear in Firestore writes
- [ ] `periodLength` does NOT appear in Firestore writes

**Issues Found:** ____________________

---

### 1.4 SharedPreferences Audit

**Verify medical data is saved locally:**

```dart
// Expected usage:
prefs.setString('liora_cycle_data_local_only', jsonEncode(data))

// NOT expected:
// Any cloud sync code
// Any network transmission
```

- [ ] `LocalMedicalDataService.saveMedicalData()` saves to SharedPreferences
- [ ] Medical data key is `liora_cycle_data_local_only`
- [ ] No `FirebaseFirestore` calls in medical data save path
- [ ] No HTTP requests in medical data save path

**Issues Found:** ____________________

---

## Phase 2: Runtime Network Analysis

### 2.1 Network Request Verification

**Tool:** Charles Proxy, Fiddler, or Burp Suite

- [ ] Start app and capture all network traffic
- [ ] Perform signup with test account
- [ ] View signup network requests:
  - [ ] POST to Firebase Auth
  - [ ] POST to Firestore (user document ONLY)
  - [ ] Verify NO medical data fields in payloads

**Sample Correct Request:**
```json
{
  "email": "user@example.com",
  "name": "Test User",
  "role": "user",
  "createdAt": "2024-02-22T10:00:00Z",
  "profileCompleted": false
}
```

**Sample Incorrect Request (FAIL):**
```json
{
  "email": "...",
  "lastPeriodDate": "2024-02-08",      // ✗ FAIL: Medical data!
  "cycleLength": 28,                   // ✗ FAIL: Medical data!
  "profileCompleted": false
}
```

- [ ] Complete onboarding questionnaire
- [ ] Enter cycle data in onboarding
- [ ] Verify NO network requests with medical data
- [ ] Expected: Only local SharedPreferences writes

**Issues Found:** ____________________

---

### 2.2 Offline Mode Test

- [ ] Disable Wi-Fi and cellular
- [ ] Launch app (should work from local data)
- [ ] Navigate to calendar (should display)
- [ ] Verify cycle predictions display
- [ ] Check next period date is shown
- [ ] No network errors should appear
- [ ] Re-enable network (should sync only auth/commerce)

**Issues Found:** ____________________

---

### 2.3 Firebase Console Audit

**Log into Firebase Console:**

1. **Firestore Database → Collections → users**
   - [ ] Open several user documents
   - [ ] Verify NO medical data fields present
   - [ ] Expected fields: `email`, `name`, `role`, `createdAt`, `profileCompleted`
   - [ ] Unexpected fields: `lastPeriodDate`, `cycleLength`, `periodLength`

2. **Authentication → Users**
   - [ ] Verify user accounts exist
   - [ ] Note: Password hashes are Firebase-managed (OK)

3. **Database Rules**
   - [ ] Review security rules
   - [ ] Verify rules don't expose user data
   - [ ] Check read/write permissions

**Issues Found:** ____________________

---

## Phase 3: Local Storage Verification

### 3.1 SharedPreferences Content Audit

**On test device/emulator:**

```bash
# Android: Use Android Studio Device File Explorer
# Path: /data/data/com.your.app/shared_prefs/

# Check files:
- [ ] com.your.app_preferences.xml exists
- [ ] Contains "liora_cycle_data_local_only" key
- [ ] Contains JSON with cycle data structure
- [ ] NO medical data in any OTHER SharedPreferences keys

# iOS: Check app sandbox
# Path: ~/Library/Containers/com.your.app/Data/Library/Preferences/

- [ ] Cycle data file is present
- [ ] Data is encrypted by platform (not readable plaintext)
```

**Verification:**
```dart
// Run this code to verify local storage:
Future<void> auditLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final allKeys = prefs.getKeys();
  
  print('All SharedPreferences keys:');
  for (final key in allKeys) {
    if (key.contains('liora') || key.contains('cycle')) {
      print('  ✓ $key (Medical data - OK)');
    } else if (key.contains('firebase') || key.contains('auth')) {
      print('  ✓ $key (Auth data - OK)');
    } else {
      print('  ? $key (Review if necessary)');
    }
  }
}
```

**Issues Found:** ____________________

---

### 3.2 Data Deletion Verification

**Test logout/uninstall flow:**

- [ ] Log in to app
- [ ] Navigate to profile
- [ ] Tap logout
- [ ] Verify local medical data is deleted (using audit code above)
- [ ] Check SharedPreferences after logout
- [ ] Uninstall app
- [ ] Verify all app data removed from device

**Issues Found:** ____________________

---

## Phase 4: Feature Testing

### 4.1 Cycle Prediction Accuracy

- [ ] Test with known cycle data (28-day cycle, 5-day period)
- [ ] Verify calendar shows correct prediction
- [ ] Verify offline calculation is accurate
- [ ] Compare with online calculation (should be identical)

**Test Cases:**
```
[ ] 28-day cycle, 5-day period:
    - Last period: Feb 1
    - Today: Feb 15
    - Next period prediction: Mar 1 (28 days later)
    
[ ] Irregular cycles:
    - Cycle length: 21 days
    - Verify next period = last + 21 days
    
[ ] Edge case (current period):
    - Last period: Today
    - Cycle day: Day 1
    - Next period: Today + cycleLength
```

**Issues Found:** ____________________

---

### 4.2 Onboarding Data Privacy

- [ ] Start signup flow
- [ ] Enter cycle data in onboarding
- [ ] Complete onboarding
- [ ] Check network traffic (should NOT contain medical data)
- [ ] Verify data appears in local storage only

**Issues Found:** ____________________

---

## Phase 5: Documentation Audit

### 5.1 Code Comments

- [ ] `CycleProvider` has `[PRIVACY]` prefix comments
- [ ] `LocalMedicalDataService` has comprehensive documentation
- [ ] `AuthService` has privacy guard documentation
- [ ] `cycle_algorithm.dart` has offline-only documentation

**Missing Documentation:** ____________________

---

### 5.2 Policy Documentation

- [ ] `PRIVACY_POLICY.md` exists and is up-to-date
- [ ] Data classification framework is documented
- [ ] Security guarantees are listed
- [ ] Audit checklist is accessible

**Issues Found:** ____________________

---

## Phase 6: Compliance Verification

### 6.1 PRIVACY Guard in AuthService

```dart
// Verify this code exists and throws on medical fields:
Future<void> updateUserProfile({...}) async {
  final medicalFields = [
    'lastPeriodDate', 'cycleLength', 'periodLength',
    'flowLevel', 'cycleRegularity', 'pmsLevel',
  ];
  
  for (final field in medicalFields) {
    if (updates.containsKey(field)) {
      throw Exception('[PRIVACY VIOLATION] ...');
    }
  }
}
```

- [ ] Guard code is present in `AuthService.updateUserProfile()`
- [ ] Guard throws exception on medical fields
- [ ] Exception message is clear and actionable

**Issues Found:** ____________________

---

### 6.2 clearLocalData() Implementation

- [ ] `CycleProvider.clearLocalData()` exists
- [ ] Called on logout (verify in code)
- [ ] Removes all cycle data from SharedPreferences
- [ ] `LocalMedicalDataService.clearAllPrivateDataOnLogout()` exists

**Issues Found:** ____________________

---

## Phase 7: Dependency Audit

### 7.1 Third-Party Library Review

**Check pubspec.yaml for potentially problematic plugins:**

- [ ] NO analytics libraries that track medical data
  - Problematic: Firebase Analytics with custom events
  - OK: Crash reporting without medical data
  
- [ ] NO cloud sync plugins
  - Problematic: Google Drive Sync, OneDrive, iCloud Sync for SharedPreferences
  - OK: Standard SharedPreferences (platform-managed)
  
- [ ] NO health app integrations
  - Problematic: Apple HealthKit direct medical data upload
  - OK: Read-only for information display

- [ ] NO unvetted data collection libraries

**Review Results:**
```
Plugin Name          | Risk Level | Decision
-------------------|------------|----------
[Example]           | [Low/Med/High] | [Allow/Remove/Review]
```

**Issues Found:** ____________________

---

## Phase 8: CI/CD & Automation

### 8.1 Automated Tests

- [ ] Unit tests verify `cycle_provider.dart` local-only behavior
- [ ] Unit tests verify `AuthService` guards reject medical fields
- [ ] Integration tests verify offline cycle prediction
- [ ] Mock network layer to verify NO medical API calls

**Test Commands:**
```bash
flutter test test/services/cycle_provider_test.dart
flutter test test/services/auth_service_test.dart
flutter test test/home/cycle_algorithm_test.dart
```

**Issues Found:** ____________________

---

### 8.2 Linting & Analysis

- [ ] `flutter analyze` runs clean (no warnings)
- [ ] Custom lint rules check for Firestore writes to medical fields
- [ ] Pre-commit hook prevents medical field commits

**Issues Found:** ____________________

---

## Phase 9: User-Facing Security

### 9.1 Transparency Features

- [ ] App does NOT claim "cloud backup" for medical data
- [ ] Privacy settings page (if present) accurately describes data storage
- [ ] No misleading marketing about data security
- [ ] Terms of Service clearly state local-only storage

**Issues Found:** ____________________

---

### 9.2 Error Messages

- [ ] Error messages do NOT expose medical data
- [ ] Crash reports do NOT include cycle data
- [ ] Debug logs use `[PRIVACY]` prefix

**Sample Test:**
```dart
// Trigger an error and check logs
throw Exception('Test error with cycle data');
// Verify error message does NOT contain actual cycle dates
```

**Issues Found:** ____________________

---

## Final Assessment

### Summary

- **Total Items Checked:** _____ / 65
- **Passed:** _____
- **Failed:** _____
- **Issues Found:** _____

### Risk Assessment

| Risk Level | Items | Status |
|-----------|-------|--------|
| Critical | _____ | [ ] PASS [ ] FAIL |
| High | _____ | [ ] PASS [ ] FAIL |
| Medium | _____ | [ ] PASS [ ] FAIL |
| Low | _____ | [ ] PASS [ ] FAIL |

### Overall Status

**[ ] PASS - No privacy violations detected**  
**[ ] PASS WITH FINDINGS - Minor improvements recommended**  
**[ ] FAIL - Critical privacy violations must be fixed**  

### Required Actions

1. _________________________________
2. _________________________________
3. _________________________________

### Sign-Off

Auditor: _________________ Date: ________  
Manager: _________________ Date: ________  

---

**Note:** This checklist should be completed:
- [ ] Before every production release
- [ ] Monthly during development
- [ ] After any medical-data-related code changes
- [ ] When dependencies are updated
