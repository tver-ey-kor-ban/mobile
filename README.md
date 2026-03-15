
# 🚀 Project Name

Garage Mobile is the NERD version of Garage Fix.
Since it is not part of the main Garage Fix system, this project focuses on providing users with an easier way to find vehicle repair and servicing providers.
The aim is to simplify the process of discovering nearby garages, booking services, and improving the user experience in vehicle maintenance. 

---

## 📦 Tech Stack
- **Flutter** (Stable Channel)
- **Dart**

## 📁 Project Structure
my_app/
 ├── lib/
 │    ├── app/              # App initialization, routing, DI, global config
 │    ├── core/             # Shared logic, constants, utilities, services
 │    ├── features/         # Modular feature architecture
 │    │     ├── auth/       # Authentication module
 │    │     ├── home/       # Home dashboard module
 │    │     ├── ai/         # AI-powered features
 │    │     └── ...         # Additional features
 │    └── shared/           # Reusable widgets, themes, and extensions
 ├── assets/                # Images, icons, fonts, JSON, static files
 ├── test/                  # Unit, widget, and integration tests
 ├── pubspec.yaml           # Dependencies & project metadata
 ├── README.md              # Documentation
 └── .gitignore             # Ignored files and directories

## 🛠️ Setup Guide

Follow the steps below to set up and run the Garage Mobile project on your local machine.

---

### ✅ 1. Prerequisites

Before starting, ensure you have the following installed:

#### ✔ Flutter (Stable Channel)
Download & install Flutter:  
https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor


## 🔌 API & Connectivity
The application communicates with the [Backend Repository](https://github.com/tver-ey-kor-ban/backend).

- **Base URL Configuration:** Update your base URL in `lib/core/network/api_constants.dart`.
- **Environment Setup:** Create a `.env` file in the root directory (ensure it's added to `.gitignore`) to manage your API keys and configuration.

## 🚀 Getting Started
1. **Clone the repo:** `git clone ...`
2. **Install Dependencies:** `flutter pub get`
3. **Generate Code:** Since we use `injectable` and `json_serializable`, run the builder:
   ```bash
   dart run build_runner build --delete-conflicting-outputs


### 3. State Management & DI Workflow
Since you mentioned `Bloc` and `GetIt`, explain the flow so others don't have to guess where to look.

```markdown
## 🏗 Development Workflow
- **Adding a Feature:** Use the folder structure provided. Create the `domain` layer first, then implement the `data` layer, and finally build the `presentation` layer with BLoC.
- **Dependency Injection:** Register new classes in your `injection_container.dart` file using the `@injectable` annotation.
- **State Changes:** Use BLoC events to trigger UseCases from the domain layer.

## 🧪 Testing
- **Unit Tests:** Located in `test/` (mimicking `lib/` structure). Focus on testing `UseCases` and `Repositories`.
- **Widget Tests:** Located in `test/presentation/`.
- **Run all tests:** `flutter test`