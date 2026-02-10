# LIORA - Privacy-First Menstrual Wellness App 🌸

A beautiful, privacy-focused menstrual wellness Android application built with Flutter.

## ✨ Features

- **Privacy First**: All sensitive menstrual data is stored locally on your device only. No cloud sync of biological data.
- **Cycle Tracking**: Track your periods with an intuitive, color-coded calendar
- **Smart Predictions**: On-device algorithm predicts your next period based on historical data
- **Gentle Notifications**: Optional, emotionally neutral reminders
- **Beautiful UI**: Calm, feminine design with smooth animations
- **Symptom Logging**: Track mood, symptoms, and notes for each day

## 🛡️ Privacy

LIORA is designed with privacy as a core principle:

| Data Type | Storage Location |
|-----------|-----------------|
| Email/UID | Firebase (Auth only) |
| Cycle Dates | **Local Device ONLY** |
| Period Length | **Local Device ONLY** |
| Symptoms | **Local Device ONLY** |
| Predictions | Generated On-Device |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.2.0 or higher
- Android Studio with Android SDK
- Firebase project (for authentication)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/liora.git
   cd liora
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com
   - Add an Android app with package name `com.liora.liora`
   - Download `google-services.json` and place it in `android/app/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. Run the app:
   ```bash
   flutter run
   ```

## 🎨 Design System

LIORA uses a calming, feminine color palette:

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Pink | `#FDE2EA` | Cards, highlights |
| Background | `#FFF6F9` | App background |
| Accent Rose | `#F7B2C4` | Buttons, active states |
| Period Day | `#FFB5C2` | Calendar period markers |
| Fertile Window | `#E8D5F2` | Calendar fertile markers |

## 📱 Screens

1. **Splash Screen** - Beautiful animated entry
2. **Login/Signup** - Firebase authentication with gentle UX
3. **Onboarding** - AirPods-style bottom sheet flow
4. **Home** - Cycle status and calendar
5. **Day Details** - Log symptoms, mood, and notes
6. **Profile** - Settings and data management

## 🔧 Architecture

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── theme/
│   │   └── liora_theme.dart
│   ├── services/
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   └── engine/
│       └── prediction_engine.dart
└── features/
    ├── auth/
    ├── onboarding/
    ├── home/
    └── cycle/
```

## 📄 License

This project is licensed under the MIT License.

## 💝 Vision

LIORA exists to **care for rhythm, not control it**. 
It is quiet, gentle, private, and human.
