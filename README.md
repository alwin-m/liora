

# Liora -  Advanced Women's Health & Cycle Intelligence 🌸

**Liora** is a premium, high-performance women's wellness ecosystem built with **Flutter**. It empowers users through algorithmic period predictions, integrated e-commerce capabilities, and empathetic AI interaction—all packaged in a modern, Material 3 aesthetic.

---

## 🌟 Key Features

### 📅 Advanced Cycle Tracking
- **Intelligent Predictions**: Algorithmic accuracy for periods, ovulation, and fertile windows.
- **Phase Analysis**: Deep insights into cycle phases (Follicular, Ovulation, Luteal) based on biological markers.
- **Historical Records**: Seamless tracking of past cycles for high-accuracy statistical modeling.

### 🛍️ Integrated E-Commerce
- **Curated Storefront**: Dedicated shop for wellness, medical, and hygiene products.
- **Smart Cart & Orders**: Fully managed state (`Provider`-backed) for item management and secure checkout.
- **Stock Management**: Real-time stock status sync for health products.

### 👨‍💼 Professional Governance
- **Admin Dashboard**: Comprehensive dashboard for administrative control over users, products, and insights.
- **Centralized Management**: Admin-only views for adding products, managing users, and monitoring system stats.

### 🔔 Smart Ecosystem
- **Local Notifications**: Timezone-aware reminders for upcoming periods and health tasks.
- **Adaptive UI**: High-contrast Dark and Light modes with persistent theme state.

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
