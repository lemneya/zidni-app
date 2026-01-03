import 'package:flareline_uikit/core/mvvm/base_viewmodel.dart';
import 'package:flareline_uikit/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:zidni_admin/services/firebase_service.dart';

class SignInProvider extends BaseViewModel {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;

  SignInProvider(BuildContext ctx) : super(ctx) {
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    SnackBarUtil.showSnack(context, 'Google Sign-In coming soon');
    // TODO: Implement Google Sign-In for admin
  }

  Future<void> signInWithGithub(BuildContext context) async {
    SnackBarUtil.showSnack(context, 'GitHub Sign-In coming soon');
    // TODO: Implement GitHub Sign-In for admin
  }

  Future<void> signIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    // Validation
    if (email.isEmpty || password.isEmpty) {
      SnackBarUtil.showSnack(context, 'Please enter email and password');
      return;
    }
    
    if (!email.contains('@')) {
      SnackBarUtil.showSnack(context, 'Please enter a valid email');
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final credential = await _firebaseService.signIn(email, password);
      
      if (credential != null) {
        // Successfully signed in as admin
        if (context.mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'Sign in failed';
        
        if (e.toString().contains('Access denied')) {
          errorMessage = 'Access denied. Admin privileges required.';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'No account found with this email';
        } else if (e.toString().contains('too-many-requests')) {
          errorMessage = 'Too many attempts. Please try again later.';
        }
        
        SnackBarUtil.showSnack(context, errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> signOut(BuildContext context) async {
    await _firebaseService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/signIn', (route) => false);
    }
  }
  
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
