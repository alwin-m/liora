# Liora Technical Reference

This guide provides an in-depth look at the architecture, modules, and internal logic of the Liora project.

## Module Breakdown

### Core Logic (`lib/core/`)
- **`cycle_session.dart`**: Global state management for Menstrual Cycle Tracking. It provides a singleton accessor for the current user's profile and cycle data.
- **`cycle_algorithm.dart`**: Contains the core logic for calculating predictions, phase analysis, and cycle statistics.
- **`advanced_cycle_profile.dart`**: Data model for users' complex cycle profiles.
- **`notification_service.dart`**: Centralized service for scheduling, canceling, and managing local notifications. Uses timezone support.
- **`app_settings.dart`**: Persistence layer for user preferences like Dark Mode and other UI settings.
- **`local_storage.dart`**: A generic wrapper around `SharedPreferences` for type-safe key-value storage.

### Service Layer (`lib/services/`)
- **`product_service.dart`**: CRUD operations and queries for the Firestore products collection.
- **`order_service.dart`**: Logic for handling order placement and history retrieval.
- **`cart_provider.dart`**: State management for the shopping cart using the `Provider` pattern.

### Feature Modules
- **`home/`**: Contains dashboard-related screens and widgets.
- **`admin/`**: Admin-only interface for product management, user stats, and system settings.
- **`shop/`**: E-commerce UI including product lists, details, and checkout flows.
- **`onboarding/`**: Interactive questionnaire used to initialize a new user's cycle profile.
- **`Screens/`**: Generic app screens like Auth screens (Signup, Login, Verify Email) and Profile management.

---

## State Management Architecture

### Provider Integration
The application uses the `Provider` package for state management. The primary provider is `CartProvider`, which is injected at the root of the app in `main.dart`.

```dart
runApp(
  ChangeNotifierProvider(
    create: (_) => CartProvider(),
    child: const MyApp(),
  ),
);
```

### Values & Listenables
For simple reactive state like theme mode, `ValueNotifier` and `ValueListenableBuilder` are used to minimize widget rebuilds without the overhead of full state management classes.

---

## Firebase Infrastructure

### Authentication
- Method: Email & Password.
- Features: Mandatory Email Verification, Password Reset.

### Cloud Firestore (NoSQL)
- `users`: Stores core profile data.
- `products`: Stores catalog for the shop.
- `orders`: Tracks user purchases.

### Firebase Storage
Used for product images and user avatars.

---

## Notification Logic

The `NotificationService` handles period reminders. It calculates the next period date using `CycleAlgorithm` and schedules a notification at a specific time (usually 8:00 AM) on the predicted day.

- **Dependency**: `flutter_local_notifications`
- **Timezone Support**: `timezone/data/latest.dart`

---

## Technical Constraints & Standards

### Platforms
The app is engineered for cross-platform compatibility:
- **Mobile**: Android (API 21+), iOS (11.0+)
- **Desktop**: Windows, macOS, Linux (Material 3 enabled)
- **Web**: Progressive Web App support

### Dependency Management
Major packages currently in use:
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `provider`
- `flutter_local_notifications`
- `shared_preferences`
- `table_calendar`

---

**Version**: 1.2.0  
**Updated**: March 26, 2026
