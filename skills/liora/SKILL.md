---
name: liora-main
description: Development, architecture, and maintenance of the Liora women's health Flutter application. Use for cycle tracking logic, Firebase integration, and UI features.
license: Custom
compatibility: Requires Flutter 3.8+, Dart 3.8+, Firebase project
metadata:
  author: Alwin Madhu
  version: "1.3.0"
  contact: alwinmadhu4060@gmail.com
  platforms:
    - Android
    - iOS
    - Windows
    - Linux
    - macOS
    - Web
---

# Liora Flutter App - Developer Skill Guide

## Project Overview

**Liora** is a premium women's health application built with Flutter. It focuses on providing a secure, high-performance, and feature-rich experience for menstrual health tracking and wellness products.

### Core Pillars
- 📅 **Advanced Cycle Intelligence**: Algorithmic predictions and phase analysis.
- 🛍️ **Integrated E-Commerce**: Seamless shopping experience for health products.
- 👨‍💼 **Admin Governance**: Full control over content and user management.
- 🌓 **Adaptive Aesthetics**: Intelligent light/dark mode with custom themes.

### Core Design Philosophy (The Liora Way)
- 🧘 **Ikigai Principles**: Every design element and feature must have a **reason** for existence. Ask "Why are we creating this?" before implementing.
- 🎨 **Intuitive over Interesting**: Prioritize clarity and ease of navigation. A beginner should understand the app's purpose and functionality instantly.
- ⚡ **Performance first**: The app must feel as smooth and fast as top-tier apps (Instagram, WhatsApp). Minimize jank and optimize transitions.
- 📖 **Meaningful Usage**: Focus on making users' lives better, easier, and more stable. Design should showcase ability and speed.
- 🧠 **Common Sense UX**: If it's hard to explain, it's poorly designed. People should "sense" the functionality before they even click.

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
    subgraph Security
        App --> Sec[SecurityService]
        Sec --> SS[SecureStorageService]
        SS --> FS[FlutterSecureStorage]
    end
```

---

## Development Prerequisites

1. **Flutter SDK**: ^3.8.1
2. **Firebase**: Project configured via `flutterfire configure`.
3. **Environment**: Ensure `google-services.json` and `GoogleService-Info.plist` are in place.

---

## Core Operational Rules

1. **Initialization Order**:
   - `WidgetsFlutterBinding.ensureInitialized()`
   - `Firebase.initializeApp()`
   - `CycleSession.initialize()`
   - `NotificationService.initialize()`
2. **State Management**:
   - Use `Provider` for cross-feature state (e.g., `CartProvider`).
   - Use `CycleSession` (Singleton) for cycle data.
   - Use `themeNotifier` (ValueNotifier) for theme switching.
3. **Coding Standards**:
   - Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).
   - Use `_Screen` suffix for all screen widgets.
   - Prefer `async`/`await` over `.then()`.

---

## Security Architecture & Data Protection

Liora implements a multi-layered security model to ensure user data remains private and protected on the device.

### 1. Multi-Factor Authentication (App Lock)
- **Biometric Integration**: Supports fingerprint and face-unlock via `local_auth`.
- **Custom Security PIN**: Users can set a 4-digit PIN stored as a SHA-256 hash in secure storage.
- **Fail-Safe Fallback**: If PIN or biometrics are forgotten, the app enforces a logout. Users must re-authenticate with their primary Liora account credentials (email/password) to reset the device lock.

### 2. Physical Data Protection (Encryption)
- **Sensitive Storage**: Uses `FlutterSecureStorage` (Keychain for iOS, Keystore for Android) to store PINs and personal delivery details.
- **Data Isolation**: All local data (Cycle history, preferences, profile) is scoped using the Firebase UID as a key prefix. This prevents data leakage if a different user logs into the same device.

### 3. Privacy Protocols
- **Notification Privacy**: Cycle alerts provided as system notifications remain visible while the app is locked, but viewing the internal calendar or dashboard requires full authentication.
- **Local-First Storage**: Personal delivery details (Address, Phone, Name) for checkout autofill are stored exclusively in the device's secure enclave and never synced to unencrypted cloud databases.

---

**Last Updated**: April 2, 2026  
**Status**: ENHANCED (Security Update v1.3.0)
