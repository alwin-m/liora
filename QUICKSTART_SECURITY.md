# Quick Start Guide - Liora App Lock & Profile Integration

**Last Updated:** April 2, 2026

---

## 🚀 5-Minute Setup

### Step 1: Verify Dependencies in `pubspec.yaml`

Ensure these packages are already in your `pubspec.yaml`:

```yaml
dependencies:
  local_auth: ^2.3.0              # ✅ Biometric
  flutter_secure_storage: ^9.2.4  # ✅ Secure PIN storage
  firebase_auth: ^6.1.3           # ✅ Cloud auth
  firebase_core: ^4.4.0           # ✅ Firebase
  shared_preferences: ^2.2.2       # ✅ App settings
  crypto: ^3.0.6                  # ✅ SHA256 hashing
```

Run:
```bash
flutter pub get
```

---

### Step 2: Add Profile Route (Main.dart)

Update your `lib/main.dart` routes to include:

```dart
// ... existing imports ...
import 'Screens/profile_screen.dart';
import 'Screens/security_privacy_screen.dart';

// In MaterialApp routes:
routes: {
  '/': (context) => const SplashScreen(),
  '/signup': (context) => const SignupScreen(),
  '/login': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/profile': (context) => const ProfileScreen(),        // ← NEW
  '/security': (context) => const SecurityPrivacyScreen(), // ← NEW
  // ... other routes ...
},
```

---

### Step 3: Integrate Logout Security (Home Screen / Navigation)

Find where you handle logout and update it:

```dart
// OLD
Future<void> _handleLogout() async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}

// NEW
import '../core/security_service.dart';

Future<void> _handleLogout() async {
  // 🔐 Security cleanup (IMPORTANT)
  await SecurityService.onUserLogout();
  
  // 🔑 Firebase logout
  await FirebaseAuth.instance.signOut();
  
  // 🚪 Redirect
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

### Step 4: Verify Splash Screen Lock Integration

Your `Splash_Screen.dart` should already have this. Verify it exists:

```dart
// In _startAppFlow() method:

// ✅ Check app lock BEFORE redirecting
final lockEnabled = await SecurityService.isLockEnabled();
if (lockEnabled) {
  // Show lock sheet (should already be done)
  showModalBottomSheet(
    context: context,
    builder: (context) => AppLockSheet(
      onAuthenticated: () {
        // Proceed with normal flow
      },
    ),
  );
}
```

---

### Step 5: Add Profile Link to Navigation

Update your bottom navigation or drawer to include Profile:

```dart
// Example: Bottom Navigation
BottomNavigationBarItem(
  icon: const Icon(Icons.person_outline),
  activeIcon: const Icon(Icons.person),
  label: 'Profile',
),

// Example: Navigation Drawer
ListTile(
  leading: const Icon(Icons.person),
  title: const Text('Profile'),
  onTap: () {
    Navigator.pop(context); // Close drawer
    Navigator.pushNamed(context, '/profile');
  },
),
```

---

## 📋 Files Overview

### New Files (Add to your project)
```
✅ lib/Screens/profile_screen.dart               (400+ lines)
✅ lib/core/session_security_service.dart        (120+ lines)
```

### Enhanced Files (Already in project, just verify)
```
✅ lib/core/secure_storage_service.dart          (Enhanced with docs)
✅ lib/core/security_service.dart                (Enhanced with logout)
✅ lib/widgets/app_lock_sheet.dart               (Enhanced with recovery)
```

### Existing Screens (Ready to use)
```
✅ lib/Screens/security_privacy_screen.dart      (PIN/Biometric management)
✅ lib/Screens/change_password_screen.dart       (Password change)
✅ lib/Screens/your_details_screen.dart          (Autofill data)
✅ lib/Screens/my_orders_screen.dart             (Orders list)
✅ lib/Screens/about_screen.dart                 (About & links)
```

---

## 🔐 How It Works (User Perspective)

### First Time Setup
1. User logs in
2. Navigates to Profile screen
3. Clicks "Security & App Lock"
4. Enables PIN (4 digits)
5. Optionally enables Biometric

### Daily Usage
1. User closes app
2. Opens app again
3. **Splash screen appears (2 sec)**
4. **App Lock popup slides up from bottom**
5. **User enters PIN OR uses fingerprint**
6. **App unlock → show home screen**

### Forgot PIN
1. In App Lock, tap "FORGOT PIN?"
2. Enter email + password
3. Firebase verifies credentials
4. Old PIN cleared, redirected to Security screen
5. User sets a NEW PIN

---

## 🧪 Quick Test

### Test PIN Lock
```
1. Enable app lock + set PIN (1234)
2. Close app completely
3. Reopen app
4. Should see App Lock popup
5. Enter 1234 → Should unlock
6. Try 5 wrong times → Should lockout 15 min
```

### Test Biometric
```
1. In Security screen, enable Biometric
2. Confirm with device fingerprint
3. Close app
4. Reopen app
5. Should prompt for fingerprint
6. Use fingerprint → Should unlock
```

### Test Multi-User
```
1. Log in as User A (set PIN 1111)
2. Log in as User B (set PIN 2222)
3. Switch to User A
4. Should require User A's PIN (1111)
5. User B's PIN (2222) should NOT work
```

---

## ⚠️ Important Configuration

### Android Manifest (`android/app/src/main/AndroidManifest.xml`)

Ensure biometric permissions are included:

```xml
<!-- Add these if not present -->
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
```

### iOS Permissions (`ios/Runner/Info.plist`)

Add biometric description:

```xml
<!-- Add this -->
<key>NSFaceIDUsageDescription</key>
<string>We need your face to unlock Liora securely</string>
<key>NSBiometricsUsageDescription</key>
<string>We need your fingerprint to unlock Liora securely</string>
```

---

## 🔧 Troubleshooting

### "Biometric not available on device"
- Device might not support biometrics
- User hasn't registered any biometrics
- Feature is disabled in system settings
- **Solution:** PIN still works as fallback ✅

### "App Lock not showing"
- Verify `isLockEnabled()` returns true
- Check SharedPreferences has `{uid}_app_lock = true`
- Verify AppLockSheet is properly imported
- **Solution:** Check Splash_Screen.dart integration

### "PIN doesn't work"
- User might be in lockout period
- PIN might be from a different account (wrong UID)
- Check failed attempts: `SessionSecurityService.getFailedAttempts()`
- **Solution:** Use forgot PIN recovery

### "Data not isolated between users"
- Check UID scoping: `"${uid}_app_pin"`
- Verify users have different Firebase UIDs
- Check SharedPreferences keys include UID
- **Solution:** Review SecureStorageService usage

---

## 📊 Architecture Diagram

```
┌──────────────────────────────────┐
│     ProfileScreen (Hub)          │
│  ├─ Security & Lock              │
│  ├─ Account Settings             │
│  ├─ Personal Info                │
│  ├─ Orders                       │
│  ├─ About                        │
│  └─ Logout                       │
└──────────────────────────────────┘
          ↓
      [SecurityService]
    ├─ PIN verification
    ├─ Biometric auth
    └─ Logout cleanup
          ↓
  [SecureStorageService]
   + [SessionSecurityService]
  ├─ Encrypted storage
  ├─ Attempt tracking
  └─ User isolation (UID)
          ↓
      [Firebase Auth / OS]
   ├─ Password management
   ├─ Biometric (device)
   └─ Cloud-based security
```

---

## 📈 What's Protected

✅ **PIN Storage** - SHA256 hashed, never raw  
✅ **Biometric** - Handled by OS, never stored locally  
✅ **Personal Data** - Encrypted in Secure Storage  
✅ **Password** - Managed by Firebase Auth  
✅ **Multi-user** - Isolated by UID  
✅ **Brute force** - 5-attempt lockout  
✅ **Session** - Cleared on logout  
✅ **Network** - TLS encryption  

---

## 🎯 Next Steps

1. **Review** `SECURITY_COMPREHENSIVE.md` for deep-dive
2. **Test** all features using the test checklist above
3. **Deploy** to beta
4. **Monitor** failed attempts and user feedback
5. **Iterate** based on security audit results

---

## 📞 Documentation

- **Main Guide:** SECURITY_COMPREHENSIVE.md
- **Implementation:** IMPLEMENTATION_SUMMARY.md (this file)
- **Code Docs:** Read inline comments in Java/Dart files
- **Questions?** Check the threat analysis section in SECURITY_COMPREHENSIVE.md

---

**🚀 You're ready to launch the enhanced security system!**

