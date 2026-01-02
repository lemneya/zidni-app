import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_repository.dart';
import '../models/user_profile.dart';

/// Firebase authentication repository.
/// Provides phone and email authentication when Firebase is configured.
/// Falls back gracefully if Firebase is not available.
class FirebaseAuthRepository implements AuthRepository {
  static const String _userProfileKey = 'zidni_user_profile';
  
  fb.FirebaseAuth? _firebaseAuth;
  UserProfile? _currentUser;
  bool _firebaseInitialized = false;
  final StreamController<UserProfile?> _authStateController = 
      StreamController<UserProfile?>.broadcast();

  // Phone verification state
  String? _verificationId;
  int? _resendToken;

  FirebaseAuthRepository() {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        _firebaseAuth = fb.FirebaseAuth.instance;
        _firebaseInitialized = true;
        _listenToAuthChanges();
      }
    } catch (e) {
      // Firebase not configured, will use local-only mode
      _firebaseInitialized = false;
    }
    
    // Load any stored user profile
    await _loadStoredUser();
  }

  void _listenToAuthChanges() {
    _firebaseAuth?.authStateChanges().listen((fb.User? user) async {
      if (user != null) {
        _currentUser = await _userProfileFromFirebaseUser(user);
        await _saveUserLocally(_currentUser!);
        _authStateController.add(_currentUser);
      } else {
        // Check if we have a local guest user
        await _loadStoredUser();
      }
    });
  }

  Future<UserProfile> _userProfileFromFirebaseUser(fb.User user) async {
    // Try to load existing profile to preserve profession data
    final existingProfile = await _loadStoredUserProfile();
    
    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? existingProfile?.displayName,
      email: user.email,
      phone: user.phoneNumber,
      profession: existingProfile?.profession,
      subProfession: existingProfile?.subProfession,
      createdAt: existingProfile?.createdAt ?? DateTime.now(),
      isGuest: false,
    );
  }

  Future<UserProfile?> _loadStoredUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userProfileKey);
    if (userJson != null) {
      try {
        return UserProfile.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _loadStoredUser() async {
    _currentUser = await _loadStoredUserProfile();
    _authStateController.add(_currentUser);
  }

  Future<void> _saveUserLocally(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser == null) {
      await _loadStoredUser();
    }
    return _currentUser;
  }

  /// Initiates phone verification. Call this first, then use signInWithPhone
  /// with the verification code received via SMS.
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String error) onError,
    required Function(UserProfile user) onAutoVerified,
  }) async {
    if (!_firebaseInitialized || _firebaseAuth == null) {
      onError('Firebase غير متوفر'); // Firebase not available
      return;
    }

    await _firebaseAuth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        // Auto-verification (Android only)
        try {
          final userCredential = await _firebaseAuth!.signInWithCredential(credential);
          if (userCredential.user != null) {
            _currentUser = await _userProfileFromFirebaseUser(userCredential.user!);
            await _saveUserLocally(_currentUser!);
            _authStateController.add(_currentUser);
            onAutoVerified(_currentUser!);
          }
        } catch (e) {
          onError(e.toString());
        }
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        onError(e.message ?? 'فشل التحقق'); // Verification failed
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  @override
  Future<UserProfile?> signInWithPhone(String phoneNumber, String verificationCode) async {
    if (!_firebaseInitialized || _firebaseAuth == null || _verificationId == null) {
      return null;
    }

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: verificationCode,
      );
      final userCredential = await _firebaseAuth!.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        _currentUser = await _userProfileFromFirebaseUser(userCredential.user!);
        await _saveUserLocally(_currentUser!);
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      // Sign in failed
      return null;
    }
    return null;
  }

  @override
  Future<UserProfile?> signInWithEmail(String email, String password) async {
    if (!_firebaseInitialized || _firebaseAuth == null) {
      return null;
    }

    try {
      final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _currentUser = await _userProfileFromFirebaseUser(userCredential.user!);
        await _saveUserLocally(_currentUser!);
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      // Sign in failed
      return null;
    }
    return null;
  }

  @override
  Future<UserProfile?> createAccountWithEmail(String email, String password) async {
    if (!_firebaseInitialized || _firebaseAuth == null) {
      return null;
    }

    try {
      final userCredential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        _currentUser = await _userProfileFromFirebaseUser(userCredential.user!);
        await _saveUserLocally(_currentUser!);
        _authStateController.add(_currentUser);
        return _currentUser;
      }
    } catch (e) {
      // Account creation failed
      return null;
    }
    return null;
  }

  @override
  Future<UserProfile> continueAsGuest() async {
    final guestUser = UserProfile.guest();
    await _saveUserLocally(guestUser);
    _currentUser = guestUser;
    _authStateController.add(_currentUser);
    return guestUser;
  }

  @override
  Future<void> updateProfession(String profession, String? subProfession) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        profession: profession,
        subProfession: subProfession,
      );
      await _saveUserLocally(_currentUser!);
      _authStateController.add(_currentUser);
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(displayName: displayName);
      await _saveUserLocally(_currentUser!);
      
      // Also update Firebase display name if authenticated
      if (!_currentUser!.isGuest && _firebaseAuth?.currentUser != null) {
        await _firebaseAuth!.currentUser!.updateDisplayName(displayName);
      }
      
      _authStateController.add(_currentUser);
    }
  }

  @override
  Future<void> signOut() async {
    if (_firebaseInitialized && _firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  bool get isGuest => _currentUser?.isGuest ?? true;

  @override
  bool get isFirebaseAvailable => _firebaseInitialized;

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
