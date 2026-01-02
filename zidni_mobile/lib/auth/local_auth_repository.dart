import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';
import '../models/user_profile.dart';

/// Local authentication repository for offline/guest mode.
/// Stores user profile locally using SharedPreferences.
class LocalAuthRepository implements AuthRepository {
  static const String _userProfileKey = 'zidni_user_profile';
  
  UserProfile? _currentUser;
  final StreamController<UserProfile?> _authStateController = 
      StreamController<UserProfile?>.broadcast();

  LocalAuthRepository() {
    _loadStoredUser();
  }

  Future<void> _loadStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userProfileKey);
    if (userJson != null) {
      try {
        _currentUser = UserProfile.fromJson(jsonDecode(userJson));
        _authStateController.add(_currentUser);
      } catch (e) {
        // Invalid stored data, clear it
        await prefs.remove(_userProfileKey);
      }
    }
  }

  Future<void> _saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
    _currentUser = user;
    _authStateController.add(_currentUser);
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser == null) {
      await _loadStoredUser();
    }
    return _currentUser;
  }

  @override
  Future<UserProfile?> signInWithPhone(String phoneNumber, String verificationCode) async {
    // Local repository doesn't support Firebase phone auth
    // Return null to indicate Firebase is not available
    return null;
  }

  @override
  Future<UserProfile?> signInWithEmail(String email, String password) async {
    // Local repository doesn't support Firebase email auth
    // Return null to indicate Firebase is not available
    return null;
  }

  @override
  Future<UserProfile?> createAccountWithEmail(String email, String password) async {
    // Local repository doesn't support Firebase account creation
    // Return null to indicate Firebase is not available
    return null;
  }

  @override
  Future<UserProfile> continueAsGuest() async {
    final guestUser = UserProfile.guest();
    await _saveUser(guestUser);
    return guestUser;
  }

  @override
  Future<void> updateProfession(String profession, String? subProfession) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        profession: profession,
        subProfession: subProfession,
      );
      await _saveUser(updatedUser);
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(displayName: displayName);
      await _saveUser(updatedUser);
    }
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  bool get isGuest => _currentUser?.isGuest ?? true;

  @override
  bool get isFirebaseAvailable => false;

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
