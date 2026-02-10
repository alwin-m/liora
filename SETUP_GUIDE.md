# LIORA - Complete Setup & Run Guide

## Your Environment
- **Flutter SDK**: `C:\project\flutter`
- **Android SDK**: `C:\Users\ALWIN\AppData\Local\Android\sdk`

---

## Step 1: Add Flutter to PATH (One-Time Setup)

Open PowerShell as Administrator and run:
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\project\flutter\bin", "User")
```

Then **restart your terminal/VS Code** for the change to take effect.

---

## Step 2: Set Up Android Emulator

### Option A: Using Android Studio (Recommended)
1. Open **Android Studio**
2. Go to **Tools → Device Manager** (or click the phone icon in toolbar)
3. Click **Create Device**
4. Select: **Pixel 6** (or any phone) → Next
5. Download: **API 34 (Android 14)** or **API 33 (Android 13)** → Next
6. Finish and click the **Play ▶ button** to start emulator

### Option B: Using Command Line (After Step 1)
```powershell
# List available emulators
C:\project\flutter\bin\flutter emulators

# Launch an emulator
C:\project\flutter\bin\flutter emulators --launch <emulator_name>
```

---

## Step 3: Check Flutter Environment

Run this command to verify everything is set up:
```powershell
C:\project\flutter\bin\flutter doctor -v
```

Fix any issues it reports (usually Android licenses).

To accept Android licenses:
```powershell
C:\project\flutter\bin\flutter doctor --android-licenses
```

---

## Step 4: Run LIORA

### Method 1: Using Terminal
```powershell
cd c:\Users\ALWIN\OneDrive\Documents\liora

# Get dependencies
C:\project\flutter\bin\flutter pub get

# Check connected devices
C:\project\flutter\bin\flutter devices

# Run the app
C:\project\flutter\bin\flutter run
```

### Method 2: Using Android Studio
1. Open Android Studio
2. Open project: `c:\Users\ALWIN\OneDrive\Documents\liora`
3. Wait for Gradle sync to complete
4. Select your emulator from the device dropdown
5. Click the green **Run ▶** button

### Method 3: Using VS Code
1. Open LIORA folder in VS Code
2. Install **Flutter extension** if not installed
3. Open Command Palette (Ctrl+Shift+P)
4. Type: `Flutter: Select Device` and choose your emulator
5. Press **F5** or go to Run → Start Debugging

---

## Troubleshooting Common Issues

### "Emulator not starting"
1. Open Android Studio → Tools → SDK Manager
2. Go to SDK Tools tab
3. Ensure these are installed:
   - Android Emulator
   - Android Emulator Hypervisor Driver (if Intel CPU)
   - Intel x86 Emulator Accelerator (HAXM) (if Intel CPU)
   - Android SDK Platform-Tools

### "HAXM not installed" (Intel CPUs only)
1. Enable Virtualization in BIOS (VT-x or VT-d)
2. Re-install HAXM from SDK Manager

### "Emulator is slow"
- Use x86_64 system image instead of ARM
- Allocate more RAM to emulator (2048MB minimum)
- Enable Hardware Acceleration in emulator settings

### "Gradle build failed"
```powershell
cd c:\Users\ALWIN\OneDrive\Documents\liora\android
.\gradlew clean
cd ..
C:\project\flutter\bin\flutter clean
C:\project\flutter\bin\flutter pub get
```

### "Firebase initialization failed"
You need to add your real Firebase API key:
1. Go to Firebase Console → Project Settings
2. Copy the API key
3. Replace `AIzaSyD-PLACEHOLDER-REPLACE-WITH-ACTUAL-KEY` in:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart`

---

## Quick Commands Reference

| Command | What it does |
|---------|-------------|
| `flutter doctor` | Check environment setup |
| `flutter pub get` | Install dependencies |
| `flutter clean` | Clean build files |
| `flutter devices` | List connected devices |
| `flutter run` | Run the app |
| `flutter run --release` | Run release version |
| `flutter build apk` | Build APK file |

---

## Ready to Run?

Once you have:
1. ✅ Emulator running (visible in Android Studio Device Manager)
2. ✅ Dependencies installed (`flutter pub get`)
3. ✅ Firebase API key added (or temporarily disabled)

Run:
```powershell
C:\project\flutter\bin\flutter run
```

The app will compile and install on your emulator!
