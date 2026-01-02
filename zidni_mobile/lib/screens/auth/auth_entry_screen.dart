import 'package:flutter/material.dart';
import '../../auth/auth_repository.dart';
import '../../auth/firebase_auth_repository.dart';
import '../../auth/local_auth_repository.dart';
import 'profession_picker_screen.dart';

/// Arabic-first authentication entry screen.
/// Offers: Phone, Email, or Skip (continue as guest).
class AuthEntryScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback? onAuthComplete;

  const AuthEntryScreen({
    super.key,
    required this.authRepository,
    this.onAuthComplete,
  });

  @override
  State<AuthEntryScreen> createState() => _AuthEntryScreenState();
}

class _AuthEntryScreenState extends State<AuthEntryScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Phone auth state
  bool _showPhoneInput = false;
  bool _showVerificationInput = false;
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();

  // Email auth state
  bool _showEmailInput = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isCreatingAccount = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.authRepository.continueAsGuest();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfessionPickerScreen(
              authRepository: widget.authRepository,
              onComplete: widget.onAuthComplete,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('حدث خطأ. حاول مرة أخرى.'); // An error occurred. Try again.
    }
  }

  Future<void> _startPhoneAuth() async {
    if (!widget.authRepository.isFirebaseAvailable) {
      _showError('تسجيل الدخول بالهاتف غير متوفر حالياً'); // Phone login not available
      return;
    }

    setState(() {
      _showPhoneInput = true;
      _showEmailInput = false;
      _clearError();
    });
  }

  /// Validates phone number format
  bool _isValidPhone(String phone) {
    // Accept international format: +XX XXXXXXXXX (8-15 digits after country code)
    final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    return phoneRegex.hasMatch(cleanPhone);
  }

  Future<void> _verifyPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showError('الرجاء إدخال رقم الهاتف'); // Please enter phone number
      return;
    }

    if (!_isValidPhone(phone)) {
      _showError('رقم الهاتف غير صالح. يجب أن يبدأ بـ + ورمز الدولة'); // Invalid phone number. Must start with + and country code
      return;
    }

    setState(() {
      _isLoading = true;
      _clearError();
    });

    if (widget.authRepository is FirebaseAuthRepository) {
      final firebaseRepo = widget.authRepository as FirebaseAuthRepository;
      await firebaseRepo.verifyPhoneNumber(
        phone,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _showVerificationInput = true;
            _isLoading = false;
          });
        },
        onError: (error) {
          _showError(error);
        },
        onAutoVerified: (user) {
          _navigateToProfessionPicker();
        },
      );
    } else {
      _showError('تسجيل الدخول بالهاتف غير متوفر'); // Phone login not available
    }
  }

  Future<void> _submitVerificationCode() async {
    final code = _verificationCodeController.text.trim();
    if (code.isEmpty) {
      _showError('الرجاء إدخال رمز التحقق'); // Please enter verification code
      return;
    }

    setState(() {
      _isLoading = true;
      _clearError();
    });

    final user = await widget.authRepository.signInWithPhone(
      _phoneController.text.trim(),
      code,
    );

    if (user != null) {
      _navigateToProfessionPicker();
    } else {
      _showError('رمز التحقق غير صحيح'); // Invalid verification code
    }
  }

  Future<void> _startEmailAuth() async {
    if (!widget.authRepository.isFirebaseAvailable) {
      _showError('تسجيل الدخول بالبريد الإلكتروني غير متوفر حالياً'); // Email login not available
      return;
    }

    setState(() {
      _showEmailInput = true;
      _showPhoneInput = false;
      _clearError();
    });
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('الرجاء إدخال البريد الإلكتروني وكلمة المرور'); // Please enter email and password
      return;
    }

    setState(() {
      _isLoading = true;
      _clearError();
    });

    final user = _isCreatingAccount
        ? await widget.authRepository.createAccountWithEmail(email, password)
        : await widget.authRepository.signInWithEmail(email, password);

    if (user != null) {
      _navigateToProfessionPicker();
    } else {
      _showError(_isCreatingAccount
          ? 'فشل إنشاء الحساب. حاول مرة أخرى.' // Account creation failed
          : 'البريد الإلكتروني أو كلمة المرور غير صحيحة'); // Invalid email or password
    }
  }

  void _navigateToProfessionPicker() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProfessionPickerScreen(
            authRepository: widget.authRepository,
            onComplete: widget.onAuthComplete,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic-first
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'تسجيل اختياري',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'سجّل لحفظ بياناتك ومزامنتها عبر أجهزتك',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Phone input section
                if (_showPhoneInput) ...[
                  _buildPhoneSection(),
                  const SizedBox(height: 20),
                ]
                // Email input section
                else if (_showEmailInput) ...[
                  _buildEmailSection(),
                  const SizedBox(height: 20),
                ]
                // Main options
                else ...[
                  _buildMainOptions(),
                ],

                const SizedBox(height: 20),

                // Skip button (always visible)
                if (!_showPhoneInput && !_showEmailInput)
                  TextButton(
                    onPressed: _isLoading ? null : _continueAsGuest,
                    child: Text(
                      'تخطي والمتابعة كضيف',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                // Back button when in input mode
                if (_showPhoneInput || _showEmailInput)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showPhoneInput = false;
                        _showEmailInput = false;
                        _showVerificationInput = false;
                        _clearError();
                      });
                    },
                    child: const Text(
                      'رجوع',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainOptions() {
    return Column(
      children: [
        // Phone button
        _buildOptionButton(
          icon: Icons.phone,
          label: 'تسجيل بالهاتف',
          onPressed: _startPhoneAuth,
          color: Colors.green,
        ),
        const SizedBox(height: 16),

        // Email button
        _buildOptionButton(
          icon: Icons.email,
          label: 'تسجيل بالبريد الإلكتروني',
          onPressed: _startEmailAuth,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: '+966 5XX XXX XXXX',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          enabled: !_showVerificationInput,
        ),
        const SizedBox(height: 16),

        if (_showVerificationInput) ...[
          TextField(
            controller: _verificationCodeController,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: 'رمز التحقق',
              hintText: '123456',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : (_showVerificationInput ? _submitVerificationCode : _verifyPhone),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _showVerificationInput ? 'تأكيد' : 'إرسال رمز التحقق',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'البريد الإلكتروني',
            hintText: 'example@email.com',
            hintTextDirection: TextDirection.ltr,
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _passwordController,
          obscureText: true,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(
            labelText: 'كلمة المرور',
            hintText: _isCreatingAccount ? '٨ أحرف على الأقل' : null,
            helperText: _isCreatingAccount ? 'يجب أن تحتوي على ٨ أحرف على الأقل' : null,
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Toggle create/login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isCreatingAccount ? 'لديك حساب؟' : 'ليس لديك حساب؟',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isCreatingAccount = !_isCreatingAccount;
                  _clearError();
                });
              },
              child: Text(
                _isCreatingAccount ? 'تسجيل الدخول' : 'إنشاء حساب',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _isCreatingAccount ? 'إنشاء حساب' : 'تسجيل الدخول',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
