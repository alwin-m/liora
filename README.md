# Liora - Private Mobile Application


![Flutter](https://img.shields.io/badge/Flutter-3.19.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth/Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![TensorFlow Lite](https://img.shields.io/badge/TensorFlow%20Lite-ML%20Insights-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

## Project Overview

**Liora** is a sophisticated, enterprise-grade private mobile application designed to provide a holistic wellness experience. It combines advanced menstrual health tracking with a seamless integrated marketplace. Built using the **Flutter** framework and **Dart**, Liora leverages high-performance state management, a robust cloud backend, and **on-device Machine Learning (TensorFlow Lite)** to ensure a secure, private, and highly personalized user experience.

---

## Application Purpose

Liora is engineered to empower users by providing:
- **Intelligent Tracking (AI-Powered):** Data-driven insights into menstrual cycles using personalized ML models (Accuracies >75%).
- **Wellness Marketplace:** A curated shop for health and wellness products with integrated order management.
- **Data Privacy (Privacy-First):** All sensitive health predictions and ML inference happen 100% locally on-device.
- **Administrative Control:** A comprehensive backend suite for managing users and inventory.
- **Personalized Recommendations:** Dynamic diet and wellness advice based on current cycle phases.

---

## Platform Support

| Platform | Support Status | Notes |
| :--- | :--- | :--- |
| **Android** | ✅ **Current Release** | Optimized for Android 10 and above with ML support. |
| **iOS** | ⏳ Planned | Future compatibility via Apple App Store. |
| **Web/Desktop** | ⏳ Planned | Cross-platform expansion in roadmap. |

---

## Technology Stack

Liora utilizes a modern, scalable technology stack:
- **Core Framework:** [Flutter](https://flutter.dev/) (SDK ^3.19.x)
- **Programming Language:** [Dart](https://dart.dev/)
- **Machine Learning:** [TensorFlow Lite](https://www.tensorflow.org/lite) for on-device inference.
- **Backend-as-a-Service (BaaS):** [Firebase](https://firebase.google.com/)
    - **Authentication:** Secure user identity management.
    - **Cloud Firestore:** Real-time NoSQL database.
    - **Cloud Storage:** Media assets and user profile storage.
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Key Dependencies:**
    - `tflite_flutter`: For on-device ML model execution.
    - `table_calendar`: For intuitive cycle visualization.
    - `cached_network_image`: For optimized shop asset loading.
    - `google_fonts`: For premium typography.
    - `shared_preferences`: For local persistence of user settings.

---

## Architecture Overview

The project follows a **Modular Layered Architecture**, emphasizing separation of concerns and maintainability. By decoupled business logic from the UI, the application ensures high testability and scalability.

- **Presentation Layer:** State-aware widgets (Provider-based) and screen compositions.
- **Business Logic Layer (Services/AI):** Providers, Service classes, and ML Inference Service handling data calculations.
- **Data Layer (Models):** Strongly typed Dart models for consistent data handling (e.g., `MLCycleData`).
- **Core Layer:** Shared utilities, themes, and application-wide configurations.

---

## Project Folder Structure

### LIB Directory Breakdown
Below is the structural representation of the core application logic:

```text
lib/
├── admin/          # Administrative dashboards and management tools
├── core/           # App-wide constants, themes, and session management
├── home/           # Main dashboard and enhanced cycle algorithms
├── models/         # Data structures (Cart, Products, MLCycleData, etc.)
├── onboarding/     # User entry flow and welcome screens
├── screens/        # Authentication, AI settings, and insights panels
├── services/       # ML Inference, AI services, and business logic
└── shop/           # Marketplace interface and commerce features
```

---

## Module Descriptions

| Module | Responsibility |
| :--- | :--- |
| **Admin** | Managing user roles, inventory updates, and viewing system-wide orders. |
| **Core** | Centralized theme data (`app_theme.dart`) and global session state. |
| **Home** | The application's heartbeat, featuring `enhanced_cycle_algorithm.dart`. |
| **AI/ML Services** | `MLInferenceService`, `AIService`, and `JournalAnalysisService`. |
| **Models** | Defines `Product`, `Order`, `MLCycleData`, and others. |
| **Onboarding** | Handles the initial user experience and profile initialization. |
| **Screens** | Contains `Login_Screen`, `CycleAIInsightsPanel`, and `AISettingsScreen`. |
| **Services** | Logic for `CartProvider`, `WellnessRecommendationService`, and `MLTrainer`. |
| **Shop** | The `ShopScreen` implementation including product browsing. |

---

## Installation & Local Development Setup

### Prerequisites
- **Flutter SDK:** ^3.19.x
- **Dart SDK:** Compatible with the installed Flutter version.
- **Python (Optional):** Required only if re-training ML models using `train_cycle_model.py`.
- **Android Studio / VS Code:** With Flutter and Dart plugins.

### Step-by-Step Setup
1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd liora
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Download/Train ML Model:**
   - Run `python train_cycle_model.py` to generate the `.tflite` model.
   - Place the model file in the `assets/` directory.

4. **Configure Firebase:**
   As this is a private project, you must provide your own `google-services.json` (for Android) and update `firebase_options.dart`.

---

## AI Implementation Guides

For detailed technical information on the AI/ML system, refer to the following local documents:
- [Quickstart Checklist](ML_QUICKSTART_CHECKLIST.md) - **Start Here**
- [Technical Roadmap](TECHNICAL_ROADM.md) - Feature implementation status.
- [AI Integration Guide](AI_INTEGRATION_GUIDE.md) - Service-level details.
- [ML Architecture Reference](ML_ARCHITECTURE_REFERENCE.md) - Neural network specifics.
- [Implementation Summary](AI_IMPLEMENTATION_SUMMARY.md) - Project overview.

---

## Running the Application

### Using Terminal
```bash
flutter run
```

---

## Android Build Instructions

To generate a signed APK:
```bash
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
> This project is **not** open-source. Unauthorized copying, redistribution, modification, or commercial usage is strictly prohibited.

- **Developer Access:** Only authorized developers listed in the Contribution section are granted access to this repository.
- **Data Privacy:** Health data is encrypted at rest and processed locally for ML predictions.
- **Local Development:** Authorized developers must use their own development environment keys and comply with internal security guidelines.

---

## Future Roadmap

- [x] **AI Insights:** Enhanced cycle prediction using machine learning patterns.
- [x] **Diet Recommendations:** Personalized phase-specific nutrition advice.
- [ ] **Deployment:** Google Play Store and Apple App Store release.
- [ ] **iOS Support:** Fine-tuning UI/UX for iOS standards.
- [ ] **Notifications:** Push notifications for cycle reminders.

---

## License & Usage Restrictions

Usage of this software is governed by a private license. All rights reserved. No part of this application may be reproduced or transmitted in any form without the express written permission of the Team Lead, **Alwin Madhu**.

---

## Version Information

**Current Version:** 1.2.0  
**Last Updated:** March 2026  
**Status:** Alpha Release (AI/ML Integrated)
