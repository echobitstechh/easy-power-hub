# Wahala HQ 🧭

> Crowdsourced problems, community-powered solutions.

Wahala HQ is a scalable Flutter application built to help users discover, report, and analyze societal challenges — called “wahalas.” The platform empowers users to propose solutions, visualize issue density via heatmaps, and monitor recurring trends through a custom pain index.

---

## 🧰 Tech Stack & Tooling

| Layer           | Tool/Package                 | Version          |
|-----------------|------------------------------|------------------|
| Flutter SDK     | `flutter`                    | `3.19.3`         |
| Dart SDK        | `dart`                       | `3.3.1`          |
| Java            | `openjdk`                    | `17.0.8`         |
| Android Gradle  | `gradle`                     | `8.4`            |
| iOS Deployment  | `Xcode`                      | `15.2+`          |
| Architecture    | `stacked`                    | `3.4.0`          |
| Dependency Mgmt | `get_it`, `stacked_services` | `8.0.0`, `1.0.0` |
| Icons           | `flutter_svg`                | `2.0.10+1`       |
| Update Checker  | `update_available`           | `0.1.4`          |
| Testing         | `mockito`, `build_runner`    | `5.4.2`, `2.4.6` |

---

## 📁 Project Structure

lib/
├── app/ # Dependency injection, routes, app-wide config
├── core/ # Base utils, theme, constants
├── features/ # Modular feature folders
│ ├── auth/
│ ├── dashboard/
│ ├── home/
│ └── ...
├── ui/
│ ├── common/ # Shared UI elements (colors, typography)
│ ├── views/ # Entry views (pages/screens)
│ └── widgets/ # Reusable UI widgets
└── main.dart # App entry point


---

## 🚀 Features

- 🔍 **Explore Feed** – Browse trending “wahalas” in your area
- 🧠 **Propose Solutions** – Suggest how to solve community problems
- 🗺️ **Heatmap View** – See where the issues cluster
- 📊 **Pain Index** – Analyze recurring or critical issues
- 📢 **Real-time Notifications**
- 🧪 **Version Checker** – Alerts users to app updates
- 🔐 **Authentication** – Register/Login with form validation and OTP flow
- 👤 **User Profile Support** – Basic personalization

---

## 🏁 Getting Started

### ✅ Prerequisites

- Flutter SDK `>=3.10.0 <4.0.0`
- Dart `>=3.3.0`
- Xcode 15+ (for iOS)
- Android SDK / Android Studio
- Java 17+
- Node.js (optional for tooling)

---

### 🧩 Setup

Clone and get dependencies:

```bash
git clone https://github.com/YOUR_USERNAME/easy_ph.git
cd easy_ph
flutter pub get


## 🧱 Architecture

### Design Pattern

- **MVVM** (Model–View–ViewModel) via [`stacked`](https://pub.dev/packages/stacked)
- **Dependency Injection** with [`get_it`](https://pub.dev/packages/get_it)
- **Navigator 2.0-style Routing** via [`stacked_services`](https://pub.dev/packages/stacked_services)
- **Widget Separation** for maintainability, reuse, and unit testing

---

### State Management

- **ViewModel-driven** logic and UI updates
- Reactive updates using:
  - `notifyListeners()` — lightweight state change notifier
  - `rebuildUi()` — specific to `stacked`, more scoped rebuilds

---

### Testing Strategy

- ✅ **ViewModels**: Unit tested using mocks and stubs (`mockito`)
- 🧪 **Widgets**: Using [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html)
- 🖼️ **Golden Tests**: Planned for consistent UI rendering
- 🔁 **Integration Tests**: Can be extended with [`integration_test`](https://pub.dev/packages/integration_test)

---

## 📦 Notable Dependencies

| Package             | Purpose                                 |
|---------------------|------------------------------------------|
| [`stacked`](https://pub.dev/packages/stacked)          | MVVM architecture + services + reactive ViewModels |
| [`flutter_svg`](https://pub.dev/packages/flutter_svg) | Rendering SVG-based icons in a performant way     |
| [`update_available`](https://pub.dev/packages/update_available) | Cross-platform version update checker             |
| [`mockito`](https://pub.dev/packages/mockito)         | Mocking services for unit tests                   |
| [`build_runner`](https://pub.dev/packages/build_runner) | Code generation for mocks, annotations, etc.      |



