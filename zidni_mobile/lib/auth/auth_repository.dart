import '../models/user_profile.dart';

/// Abstract interface for authentication operations.
/// Supports both local (offline/guest) and Firebase authentication.
abstract class AuthRepository {
  /// Returns the current user profile, or null if not authenticated.
  Future<UserProfile?> getCurrentUser();

  /// Signs in with phone number (Firebase).
  /// Returns the user profile on success.
  Future<UserProfile?> signInWithPhone(String phoneNumber, String verificationCode);

  /// Signs in with email and password (Firebase).
  /// Returns the user profile on success.
  Future<UserProfile?> signInWithEmail(String email, String password);

  /// Creates a new account with email and password (Firebase).
  /// Returns the user profile on success.
  Future<UserProfile?> createAccountWithEmail(String email, String password);

  /// Continues as guest (local only).
  /// Creates a local guest profile.
  Future<UserProfile> continueAsGuest();

  /// Updates the user's profession.
  Future<void> updateProfession(String profession, String? subProfession);

  /// Updates the user's display name.
  Future<void> updateDisplayName(String displayName);

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns true if the current user is a guest (not authenticated with Firebase).
  bool get isGuest;

  /// Returns true if Firebase authentication is available.
  bool get isFirebaseAvailable;

  /// Stream of authentication state changes.
  Stream<UserProfile?> get authStateChanges;
}
