---
name: liora-main
description: Development, architecture, and maintenance of the Liora women's health Flutter application. Use for cycle tracking logic, Firebase integration, and UI features.
license: Custom
compatibility: Requires Flutter 3.8+, Dart 3.8+, Firebase project
metadata:
  author: Alwin Madhu
  version: "1.2.0"
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

**Last Updated**: March 26, 2026  
**Status**: ACTIVE
