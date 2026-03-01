# Liora - Project Context

Liora is a private, enterprise-grade wellness mobile application built with Flutter and Firebase, featuring advanced on-device ML for menstrual cycle prediction.

## Tech Stack
- **Framework:** Flutter (3.19.x) / Dart (3.3.x)
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore, Storage)
- **AI/ML:** TensorFlow Lite (On-device inference)
- **Local Persistence:** Shared Preferences

## Key Directories
- `lib/core/` - Application-wide themes (`app_theme.dart`), constants, and session management.
- `lib/services/` - Business logic, AI/ML inference (`ml_inference_service.dart`), and API connectors.
- `lib/models/` - Strongly typed data models (`MLCycleData`, `Product`, `Order`).
- `lib/screens/` - UI screens, including specialized AI insights panels.
- `lib/home/` - Main dashboard and core cycle algorithms (`enhanced_cycle_algorithm.dart`).
- `lib/admin/` - Administrative dashboards for inventory and user management.
- `lib/shop/` - E-commerce/marketplace implementation.

## Coding Standards
- **Architecture:** Modular Layered Architecture. Keep business logic strictly in services; UI components should only handle presentation.
- **Null Safety:** Strict adherence to Dart null safety.
- **Type Safety:** Use the defined models in `lib/models/` for all data piping. Avoid `dynamic` where possible.
- **Styling:** Use `app_theme.dart` for all UI components to maintain visual consistency.
- **Privacy:** Predictions and ML inference must happen locally on-device. Sensitive health data should be handled with extreme care.

## Common Commands
```powershell
flutter pub get             # Install dependencies
flutter run                 # Run application
flutter build apk --release # Generate release APK
python train_cycle_model.py # Train local ML model
```

## Workflows
- **New Feature:** Define model -> Implement service/logic -> Build UI screen -> Register provider in `main.dart`.
- **ML Updates:** Update `MLCycleData` -> Retrain via Python script -> Replace `.tflite` in assets -> Update `MLInferenceService`.
- **UI Changes:** Always verify against `app_theme.dart` and ensure responsive layout for different Android devices.

## Important Notes
- This is a **private repository**. Do not share code or credentials externally.
- Firebase configuration (`google-services.json` / `firebase_options.dart`) is required for full functionality.
- AI predictions aim for >75% accuracy using 10+ health parameters.
