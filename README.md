# Liora - Private Mobile Application

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth/Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## Project Overview

**Liora** is a sophisticated, enterprise-grade private mobile application designed to provide a holistic wellness experience. It combines advanced menstrual health tracking with a seamless integrated marketplace. Built using the **Flutter** framework and **Dart**, Liora leverages high-performance state management and a robust cloud backend to ensure a secure, private, and responsive user experience.

---

## Application Purpose

Liora is engineered to empower users by providing:
- **Intelligent Tracking:** Data-driven insights into menstrual cycles using custom algorithms.
- **Wellness Marketplace:** A curated shop for health and wellness products with integrated order management.
- **Data Privacy:** A private-first approach where sensitive health data is handled with strict security protocols.
- **Administrative Control:** A comprehensive backend suite for managing users and inventory.

---

## Platform Support

| Platform | Support Status | Notes |
| :--- | :--- | :--- |
| **Android** | ✅ **Current Release** | Optimized for Android 10 and above. |
| **iOS** | ⏳ Planned | Future compatibility via Apple App Store. |
| **Web/Desktop** | ⏳ Planned | Cross-platform expansion in roadmap. |

---

## Technology Stack

Liora utilizes a modern, scalable technology stack:
- **Core Framework:** [Flutter](https://flutter.dev/) (SDK ^3.8.1)
- **Programming Language:** [Dart](https://dart.dev/)
- **Backend-as-a-Service (BaaS):** [Firebase](https://firebase.google.com/)
    - **Authentication:** Secure user identity management.
    - **Cloud Firestore:** Real-time NoSQL database for cycle tracking and shop data.
    - **Cloud Storage:** Media assets and user profile storage.
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Key Dependencies:**
    - `table_calendar`: For intuitive cycle visualization.
    - `cached_network_image`: For optimized shop asset loading.
    - `google_fonts`: For premium typography.
    - `shared_preferences`: For local persistence of user settings.

---

## Architecture Overview

The project follows a **Modular Layered Architecture**, emphasizing separation of concerns and maintainability. By decoupled business logic from the UI, the application ensures high testability and scalability.

- **Presentation Layer:** State-aware widgets (Provider-based) and screen compositions.
- **Business Logic Layer (Services):** Providers and Service classes handling data flow and calculations.
- **Data Layer (Models):** Strongly typed Dart models for consistent data handling.
- **Core Layer:** Shared utilities, themes, and application-wide configurations.

---

## Project Folder Structure

### LIB Directory Breakdown
Below is the structural representation of the core application logic:

```text
lib/
├── admin/          # Administrative dashboards and management tools
├── core/           # App-wide constants, themes, and session management
├── home/           # Main dashboard, calendar, and cycle algorithms
├── models/         # Data structures and entity definitions
├── onboarding/     # User entry flow and welcome screens
├── screens/        # Authentication and general purpose application screens
├── services/       # Providers, API connectors, and business logic
└── shop/           # Marketplace interface and commerce features
```

---

## Module Descriptions

| Module | Responsibility |
| :--- | :--- |
| **Admin** | Managing user roles, inventory updates, and viewing system-wide orders. |
| **Core** | Centralized theme data (`app_theme.dart`) and global session state. |
| **Home** | The application's heartbeat, including `cycle_algorithm.dart` for period predictions. |
| **Models** | Defines `Product`, `Order`, `CartItem`, and `CycleData` schemas. |
| **Onboarding** | Handles the initial user experience and profile initialization. |
| **Screens** | Contains `Login_Screen`, `Signup_Screen`, and `MyOrdersScreen`. |
| **Services** | Logic for `CartProvider`, `OrderService`, and `ProductService`. |
| **Shop** | The `ShopScreen` implementation including product browsing and interaction. |

---

## Installation & Local Development Setup

### Prerequisites
- **Flutter SDK:** ^3.8.1
- **Dart SDK:** Compatible with the installed Flutter version.
- **Android Studio / VS Code:** With Flutter and Dart plugins.
- **Java Development Kit (JDK):** Version 11 or 17.

### Step-by-Step Setup
1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd lioraa
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**
   As this is a private project, you must provide your own `google-services.json` (for Android) and initialize Firebase using the FlutterFire CLI or by manually updating `firebase_options.dart`.

---

## Environment Configuration & API Setup

Before running the application, ensure the following configurations are in place:
1. **Firebase Project:** Create a Firebase project and enable Auth (Email/Password), Firestore, and Storage.
2. **Manual Configuration:**
   - Update `firebase_options.dart` with your project-specific credentials.
   - Ensure the `android/app/build.gradle` file reflects your unique application ID.
3. **API Keys:** Any third-party API keys (if applicable) should be placed in a `.env` file or structured configuration class.

---

## Running the Application

### Using VS Code
1. Open the project folder in VS Code.
2. Ensure an Android emulator or physical device is connected (`flutter devices`).
3. Press `F5` or navigate to the `Run and Debug` tab and select **Start Debugging**.

### Using Terminal
```bash
flutter run
```

---

## Android Build Instructions

To generate a signed APK or App Bundle:
1. Ensure the `key.properties` file is configured in the `android/` folder.
2. Run the build command:
   ```bash
   # For App Bundle (Google Play Store)
   flutter build appbundle
   
   # For APK (Direct Installation)
   flutter build apk --release
   ```

---

## Usage Guidelines

### Navigating the Codebase
- **Business Logic:** Located in `lib/services/`. Do not place complex logic inside Widget files.
- **UI Components:** Reusable widgets should be modularized. Primary screens reside in `lib/screens/` and feature-specific folders (e.g., `lib/shop/`).
- **State Management:** Use `Provider.of<T>(context)` or `Consumer<T>` to access application state.

### Extending Features
- **Adding a New Screen:** Create the file in `lib/screens/` or a new module folder. Ensure it follows the established `app_theme.dart` for visual consistency.
- **Adding a Module:** Maintain the existing folder structure. If a new domain is introduced (e.g., `Settings`), create a corresponding folder in `lib/`.
- **Consistency:** Always use the defined `Models` for data piping to ensure type safety across the application.

---

## Contribution & Leadership

### Team Lead
- **Alwin Madhu** - *Technical Lead & Architect*

### Development Team
| Name | Role | GitHub Profile |
| :--- | :--- | :--- |
| **Alwin Madhu** | Contributor | [@alwin-m](https://github.com/alwin-m) |
| **Abhishek** | Contributor | [@abhishek-2006-7](https://github.com/abhishek-2006-7) |
| **Nejin Bejoy** | Contributor | [@nejinbejoy](https://github.com/nejinbejoy) |
| **Majumnair** | Contributor | [@Majumnair](https://github.com/Majumnair) |
| **Siraj** | Contributor | [@sirajudheen7official-boop](https://github.com/sirajudheen7official-boop) |

---

## Security & Access Policy

> [!IMPORTANT]
> **PRIVATE REPOSITORY NOTICE**
> This project is **not** open-source. Unauthorized copying, redistribution, modification, or commercial usage of any part of this repository is strictly prohibited.

- **Developer Access:** Only authorized developers listed in the Contribution section are granted access to this repository.
- **Data Privacy:** Health data is encrypted at rest and in transit where applicable via Firebase security rules.
- **Local Development:** Authorized developers must use their own development environment keys and comply with internal security guidelines.

---

## Future Roadmap

- [ ] **Deployment:** Google Play Store and Apple App Store release.
- [ ] **iOS Support:** Fine-tuning UI/UX for iOS standards.
- [ ] **Notifications:** Push notifications for cycle reminders and shop offers.
- [ ] **AI Insights:** Enhanced cycle prediction using machine learning patterns.

---

## License & Usage Restrictions

Usage of this software is governed by a private license. All rights reserved. No part of this application may be reproduced or transmitted in any form without the express written permission of the Team Lead, **Alwin Madhu**.

---

## Version Information

**Current Version:** 1.0.0+1  
**Last Updated:** February 2026  
**Status:** Alpha Release (Android Focus)
