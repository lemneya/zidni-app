# Firebase Configuration Required

## Generate firebase_options.dart

Your app requires Firebase configuration. Generate it with:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (run from zidni_mobile directory)
flutterfire configure
```

This creates `lib/firebase_options.dart` with your Firebase credentials.

## Alternative: Manual Setup

If you already have Firebase credentials, create the file manually based on your Firebase Console settings.
