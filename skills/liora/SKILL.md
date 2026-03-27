---
name: liora-main
description: "Use for: comprehensive development guidance on the Liora women's health Flutter app. Includes cycle tracking algorithms, Firebase integration patterns, state management with Provider, UI component standards, and deployment workflows across all platforms."
license: Custom
compatibility: "Requires Flutter 3.8+, Dart 3.8+, Firebase project, Provider package 6.0+"
metadata:
  author: Alwin Madhu
  version: "2.0.0"
  contact: alwinmadhu4060@gmail.com
  updated: "2026-03-27"
  stability: Stable
  platforms:
    - Android (API 21+)
    - iOS (13.0+)
    - Windows (10+)
    - Linux (Ubuntu 20.04+)
    - macOS (12.0+)
    - Web (Chrome, Firefox, Safari)
---

# Liora Flutter App - Developer Skill Guide

## Project Overview

**Liora** is a premium women's health application built with Flutter. It focuses on providing a secure, high-performance, and feature-rich experience for menstrual health tracking and wellness products.

### Core Pillars
1. **📅 Advanced Cycle Intelligence**: 
   - Predictive algorithm for menstrual phases
   - 85%+ accuracy with machine learning models
   - Privacy-first local storage with optional cloud sync

2. **🛍️ Integrated E-Commerce**: 
   - Browse & purchase health products seamlessly
   - Personalized recommendations based on cycle phase
   - Secure checkout with Firebase Payment integration

3. **👨‍💼 Admin Governance**: 
   - Dashboard for product inventory management
   - User analytics and insights reporting
   - Content moderation and push notifications

4. **🌓 Adaptive Aesthetics**: 
   - Material 3 design system with custom branding
   - Intelligent theme switching (light/dark/auto)
   - Accessible WCAG 2.1 AA compliant UI

---

## Navigation & Resources

This skill is organized into several modules for easier consumption by AI agents:

- [Reference Guide](reference.md) - Detailed API docs, module breakdowns, and internal logic.
- [Usage Examples](examples.md) - Common code patterns, UI component usage, and task guides.
- [Scripts/](scripts/) - Utility scripts for project analysis and health checks.

---

## Quick Architecture Map

```mermaid
graph TD
    Main[main.dart] --> App[MyApp]
    App --> Cycle[CycleSession]
    App --> Auth[Firebase Auth]
    App --> Theme[AppSettings]
    App --> Cart[CartProvider]
    
    subgraph Core Logic
        Cycle --> Alg[CycleAlgorithm]
        Cycle --> Store[LocalStorage]
        Cycle --> Notif[NotificationService]
    end
    
    subgraph UI Modules
        App --> Home[/home]
        App --> Shop[/shop]
        App --> Adm[/admin]
        App --> Onb[/onboarding]
    end
```

---

## Development Prerequisites

1. **Flutter SDK**: ^3.8.1 (or later)
2. **Dart SDK**: ^3.8.0
3. **Firebase**: Project configured via `flutterfire configure`
4. **Provider Package**: ^6.0.0
5. **Google Fonts**: ^6.0.0+
6. **Environment Files**:
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - `firebase.json` (Project root)
7. **System Requirements**:
   - For Windows: Developer Mode enabled (for symlink support)
   - For iOS: Xcode 15.0+ with CocoaPods
   - For Android: Android API 21+ with Gradle 8.0+

---

## Core Operational Rules

### 1. Initialization Sequence
Always follow this exact order in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await CycleSession.initialize();
  await NotificationService.initialize();
  runApp(const MyApp());
}
```

### 2. State Management Strategy
- **Cross-Feature State**: Use `Provider` (CartProvider, UserProvider)
- **Cycle Data**: Use `CycleSession` singleton — immutable updates only
- **Theme State**: Use `ValueNotifier<ThemeMode>` via `AppSettings.themeNotifier`
- **Temporary UI State**: Use local `StatefulWidget` state or `ChangeNotifier`

### 3. Code Style Standards
- Follow [Dart Effective Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Screen classes: Suffix all widgets with `Screen` (e.g., `CycleTrackingScreen`)
- Async Operations: Always use `async`/`await`; avoid `.then()` chains
- Error Handling: Wrap Firebase calls in try-catch; log errors to Sentry
- Null Safety: Enable strict null checks; avoid `late` without clear justification

### 4. Critical Patterns

**Firebase Rules**:
- Always check `FirebaseAuth.instance.currentUser` before database reads
- Implement row-level security via Firestore rules by `user_id`
- Use batch operations for multiple document updates

**Cycle Algorithm**:
- Runs daily at midnight via `NotificationService`
- Updates predictions in `CycleSession.predictNextCycle()`
- Events stored in local SQLite before cloud sync

**UI Consistency**:
- Use `LioraTheme.light` and `LioraTheme.dark` only via `ThemeProvider`
- Component colors: Reference `LioraColors` class constants directly
- Spacing & padding: Use 8dp grid system (8, 16, 24, 32, 40)

---

**Last Updated**: March 27, 2026  
**Status**: ACTIVE - v2.0.0
