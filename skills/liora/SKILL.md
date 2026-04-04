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
- 💧 **Fluid Data Visualisations**: Animated, data-driven UI metaphors (e.g., liquid-fill blood-flow containers) that translate clinical values into intuitive visuals.

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

---

## Animation & Visualisation Features

### 💧 Blood Flow Forecast Widget (`lib/widgets/blood_flow_widget.dart`)

**Purpose**: Communicate daily menstrual flow volume through a natural liquid-fill metaphor instead of clinical numbers.

**Design Protocol**:
- Each day of the period is represented as a tall rounded container ("vial").
- A sinusoidal wave surface animates continuously to suggest living, flowing liquid.
- Containers fill up *staggered and sequentially* on first render (rising animation), so the user reads left-to-right like a story.
- Fill heights follow a biologically accurate curve: low on day 1, peak on day 2–3, tapering to end.
- **Three intensity variants** driven by `AdvancedCycleProfile.flowIntensity`:
  - `0` = Light — max fill ~45%
  - `1` = Medium — max fill ~70%
  - `2` = Heavy — max fill ~90%
- Gradient goes from soft coral (`0xFFE57373`) at top to deep rose (`0xFFC1446F`) at base — matching the Liora pink palette. **Do not change these colour values.**
- Background card uses `Color(0xFFFFE3EC)` (same warm blush as the next-period card) so it blends seamlessly.

**Integration**:
Call `_bloodFlowCard()` in `home_screen.dart` inside `_homeUI()`. It reads `CycleSession.algorithm.adjustedPeriodLength` and `profile.flowIntensity` — no extra state required.

**Adding New Intensity Tiers**: Extend `_flowProfiles` map inside `BloodFlowWidget`.

---

**Last Updated**: April 4, 2026  
**Status**: ACTIVE
