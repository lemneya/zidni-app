# Zidni Developer Onboarding

Welcome to the Zidni team! This guide will help you get your development environment set up and running in under 30 minutes.

## Prerequisites

Before you begin, make sure you have the following installed:

- **Flutter SDK:** Version 3.x or higher. You can find the installation instructions on the [official Flutter website](https://flutter.dev/docs/get-started/install).
- **Android Studio:** The latest version of Android Studio is recommended. You can download it from the [Android Developer website](https://developer.android.com/studio).
- **Git:** You'll need Git to clone the repository.

## 1. Clone the Repository

Open your terminal and clone the Zidni repository:

```bash
git clone <repository-url>
cd zidni-app
```

## 2. Install Dependencies

Once you've cloned the repository, you need to install the project's dependencies. Run the following command in the `zidni-app` directory:

```bash
flutter pub get
```

## 3. Run the App

Now you're ready to run the app. Connect a device or start an emulator, and then run:

```bash
flutter run
```

The app should launch on your device/emulator. You can now start exploring the app and its features.

## 4. Run Tests and Generate Goldens

We use golden file testing to ensure UI consistency. To run the tests and generate golden files, use the following command:

```bash
flutter test --update-goldens
```

This command will run all the tests in the `test/` directory and update the golden files in `test/golden_baseline/`. Make sure to commit any changes to the golden files.

## Common Troubleshooting

- **`flutter pub get` fails:** This is often due to a network issue or a problem with the Flutter installation. Try running `flutter doctor` to diagnose the issue.
- **Golden file tests fail:** This can happen if there are unexpected UI changes. Review the changes and either update the goldens or fix the UI.

That's it! You're now ready to start contributing to Zidni. If you have any questions, feel free to ask in the team's communication channel.
