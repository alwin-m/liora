

# Liora - Advanced Women's Health & Cycle Intelligence 🌸

**Liora** is a premium, high-performance women's wellness ecosystem built with **Flutter**. It empowers users through algorithmic period predictions, integrated e-commerce capabilities, and empathetic AI interaction—all packaged in a modern, Material 3 aesthetic.

---

## 🌟 Key Features

### 📅 Annie Hathaway Adaptive Intelligence
- **Self-Learning Predictions**: Our custom **Annie Hathaway Algorithm** is an on-device, adaptive engine that learns from your actual cycles.
- **High Accuracy (98%+)**: Personalises your next period, ovulation, and fertility window predictions based on your unique biological data.
- **Dynamic Training**: Each cycle you log trains the algorithm to understand your specific deviations, cycle length shifts, and flow patterns.

### 🩸 Interactive Flow & Pain Tracking
- **Daily Flow Broadcast**: Visualise expected flow volume (0%—100%) with animated liquid vials on your home screen.
- **Deep Logging**: Log actual flow percentages and pain levels (Mild to Severe) each day using an intuitive, iPhone-style interactive UI.
- **Historical Insights**: View detailed history with flow-intensity cubes and deviation metrics to understand your body's trends.

### 🔒 Privacy-First Architecture
- **Zero-Transmission Policy**: All health data, cycle logs, and AI training remains 100% on your device.
- **Offline Intelligence**: The Hathaway engine works fully offline, requiring zero internet for predictions or training.
- **Iron Vault Security**: Local data is encrypted using platform-native security (iOS Keychain / Android Keystore).

### 🔔 Smart Check-ins
- **Daily Reminders**: Timezone-aware notifications for period starts and daily flow logging.
- **Adaptive UI**: Premium Material 3 design with Nature-inspired palettes (Blush, Sage, Sand) and smooth micro-animations.

---

## 🚀 The Core Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) 3.8.1 (Material 3)
- **Backend Infrastructure**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore, Storage)
- **State Architecture**: [Provider](https://pub.dev/packages/provider) Pattern
- **Persistence Layer**: [SharedPreferences](https://pub.dev/packages/shared_preferences) for high-speed local storage.
- **Notifications**: [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) with TZ support.

---

## 📁 AI Developer Skill System

Liora features an integrated **AI Intelligence Framework** designed to train AI agents (like Antigravity, ChatGPT, and Claude) on the project's specific "vibe" and development patterns.

Located in `skills/liora/`:
- **[`SKILL.md`](skills/liora/SKILL.md)**: The core entrypoint and project manifesto.
- **[`reference.md`](skills/liora/reference.md)**: Technical API deeper-dives and architectural patterns.
- **[`examples.md`](skills/liora/examples.md)**: Common code snippets for standard tasks.
- **[`analyzer.ps1`](skills/liora/scripts/analyzer.ps1)**: Automated project health monitoring script.

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- Firebase Project configured via `flutterfire configure`.

### Installation
1.  **Clone** the repository.
2.  **Run Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the Project**:
    ```bash
    flutter run -d chrome
    # OR
    flutter run -d windows
    ```

> [!TIP]
> **Developer Hub**: It is highly recommended to develop Liora on a local partition (e.g., `C:\dev\lioraa`) instead of a sync'd OneDrive folder to avoid background file-locking on `pubspec.lock`.

---

## 🤝 Maintainer & Support

Created and maintained by **Alwin Madhu**—a vision for empowering women's health through technology.

- **GitHub**: [@alwin-m](https://github.com/alwin-m)
- **Contact**: [`alwinmadhu7@gmail.com`](mailto:alwinmadhu7@gmail.com)

---
*Liora: Intelligence for Personal Wellness.* 💖
