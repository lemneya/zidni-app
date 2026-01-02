# Gate AUTH-1: Optional Firebase Auth + Local User Profile (Profession)

## Overview

This gate adds optional authentication and profession-based user profiles to Zidni, while maintaining full offline-first functionality. Users can continue using the app as guests without any login requirement.

## Architecture

### Auth Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      App Launch                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Check for existing user profile                 │
│                  (SharedPreferences)                         │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│   Profile exists    │         │   No profile        │
│   (Guest or Auth)   │         │   (First launch)    │
└─────────────────────┘         └─────────────────────┘
              │                               │
              ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│   Continue to app   │         │   Show Auth Entry   │
│   (full features)   │         │   (Optional)        │
└─────────────────────┘         └─────────────────────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
          ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
          │   Phone Auth    │       │   Email Auth    │       │   Skip (Guest)  │
          │   (Firebase)    │       │   (Firebase)    │       │   (Local only)  │
          └─────────────────┘       └─────────────────┘       └─────────────────┘
                    │                         │                         │
                    └─────────────────────────┼─────────────────────────┘
                                              │
                                              ▼
                              ┌─────────────────────────────┐
                              │   Profession Picker Screen  │
                              │   (Required categories)     │
                              └─────────────────────────────┘
                                              │
                                              ▼
                              ┌─────────────────────────────┐
                              │   Save profile locally      │
                              │   Continue to app           │
                              └─────────────────────────────┘
```

## Profession Categories

The following profession categories are supported, with Arabic-first labels:

| ID | Arabic | English | Sub-categories |
|----|--------|---------|----------------|
| `trader_importer` | تاجر/مستورد | Trader/Importer | None |
| `manufacturer` | مصنّع | Manufacturer | None |
| `service_provider` | مقدم خدمات | Service Provider | نجار (Carpenter), كهربائي (Electrician), سباك (Plumber), ميكانيكي (Mechanic), سائق (Driver), أخرى (Other) |
| `student` | طالب | Student | None |
| `traveler` | مسافر | Traveler | None |
| `other` | أخرى | Other | None |

## Files Created

### Core Auth Files
- `lib/auth/auth_repository.dart` - Abstract interface for authentication
- `lib/auth/local_auth_repository.dart` - Local/offline authentication (guest mode)
- `lib/auth/firebase_auth_repository.dart` - Firebase authentication (optional)

### Models
- `lib/models/user_profile.dart` - User profile model with profession support

### Screens
- `lib/screens/auth/auth_entry_screen.dart` - Arabic-first auth entry (Phone/Email/Skip)
- `lib/screens/auth/profession_picker_screen.dart` - Profession selection screen

### Widgets
- `lib/widgets/auth/auth_value_banner.dart` - Banner for guest users explaining signup benefits

### Assets
- `assets/data/professions.json` - Profession categories data

### Documentation
- `docs/gates/AUTH-1.md` - This file

## Firebase Setup (Optional)

Firebase authentication is optional. If Firebase is not configured, the app will automatically use local-only (guest) mode.

To enable Firebase authentication:

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
4. Enable Phone and/or Email authentication in Firebase Console

## Usage

### Initializing Auth Repository

```dart
// For Firebase-enabled apps
final authRepo = FirebaseAuthRepository();

// For local-only apps
final authRepo = LocalAuthRepository();
```

### Checking User State

```dart
final user = await authRepo.getCurrentUser();
if (user == null) {
  // No user, show auth entry
} else if (user.isGuest) {
  // Guest user, show auth value banner
} else {
  // Authenticated user
}
```

### Showing Auth Value Banner

```dart
AuthValueBanner(
  authRepository: authRepo,
  onAuthComplete: () {
    // Refresh UI after auth
  },
)
```

## Acceptance Criteria

- [x] App launches and works fully without login (guest mode)
- [x] Auth entry screen shows: Phone, Email, Skip
- [x] Phone auth: Firebase phone verification (if configured)
- [x] Email auth: Firebase email/password (if configured)
- [x] Skip: continues as guest, profile stored locally
- [x] If Firebase not configured, only local/guest mode available
- [x] Required profession categories present
- [x] Service Provider shows sub-categories on selection
- [x] Profession saved to UserProfile
- [x] All labels Arabic-first
- [x] Auth value banner appears only for guest users
- [x] Banner never blocks core actions
- [x] Locked files untouched (gul_control.dart, stt_engine.dart, stt_engine_speech_to_text.dart)
