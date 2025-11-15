import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/routes/route_generator.dart';
import 'package:house_rent_app/core/routes/routes.dart';
import 'package:house_rent_app/services/firestore_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  bool loading = false;
  bool obscure = true;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  // Debounce timers to prevent excessive rebuilds
  Timer? _emailDebounceTimer;
  Timer? _passwordDebounceTimer;

  @override
  void initState() {
    super.initState();
    emailCtrl.addListener(_onEmailChanged);
    passCtrl.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailDebounceTimer?.cancel();
    _passwordDebounceTimer?.cancel();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    _emailDebounceTimer?.cancel();
    _emailDebounceTimer = Timer(const Duration(milliseconds: 300), _validateEmail);
  }

  void _onPasswordChanged() {
    _passwordDebounceTimer?.cancel();
    _passwordDebounceTimer = Timer(const Duration(milliseconds: 300), _validatePassword);
  }

  void _validateEmail() {
    final email = emailCtrl.text.trim();
    final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    if (_isEmailValid != isValid) {
      setState(() => _isEmailValid = isValid);
    }
  }

  void _validatePassword() {
    final isValid = passCtrl.text.isNotEmpty;
    if (_isPasswordValid != isValid) {
      setState(() => _isPasswordValid = isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Header - extracted to separate widget
                  const _LoginHeader(),
                  const SizedBox(height: 32),

                  // Email Field - extracted
                  _EmailField(
                    controller: emailCtrl,
                    isValid: _isEmailValid,
                  ),
                  const SizedBox(height: 16),

                  // Password Field - extracted
                  _PasswordField(
                    controller: passCtrl,
                    obscure: obscure,
                    isValid: _isPasswordValid,
                    onToggleObscure: () => setState(() => obscure = !obscure),
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password - extracted
                  _ForgotPasswordButton(
                    loading: loading,
                    onPressed: _resetPassword,
                  ),
                  const SizedBox(height: 16),

                  // Sign In Button - extracted
                  _SignInButton(
                    loading: loading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),

                  // Divider - extracted
                  const _OrDivider(),
                  const SizedBox(height: 24),

                  // Register redirect - extracted
                  _RegisterRedirect(loading: loading),
                  const SizedBox(height: 24),

                  // Terms and Privacy - extracted
                  const _TermsText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final pass = passCtrl.text.trim();

    try {
      setState(() => loading = true);
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      // Try to ensure user doc with secure error handling
      try {
        await FirestoreService.instance.ensureUserDoc(cred.user!);
        log('✅ User document created/updated in Firestore');
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          log('⚠️ Firestore permission denied - check security rules');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Logged in successfully! However, there was an issue accessing your profile data. '
                        'This might be due to security settings.'),
              ),
            );
          }
        } else {
          log('⚠️ Other Firestore error: ${e.code} - ${e.message}');
        }
      } catch (e) {
        log('⚠️ Unexpected error ensuring user doc: $e');
      }

      // Success - navigate to home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          RouteGenerator.generateRoute(
            const RouteSettings(name: RouteNames.index),
          ),
        );
        log('🚀 Navigating to home screen...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged you in. Enjoy!'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _handleAuthError(e, email);
    } catch (e) {
      log('❌ General Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _handleAuthError(FirebaseAuthException e, String email) {
    String message;

    switch (e.code) {
      case 'user-not-found':
        message =
        'No account found with email: $email\n\nPlease check your email or create a new account.';
        break;
      case 'wrong-password':
        message =
        'Incorrect password for: $email\n\nPlease try again or use "Forgot Password" to reset it.';
        break;
      case 'invalid-email':
        message =
        'The email address "$email" is not valid.\n\nPlease check and try again.';
        break;
      case 'user-disabled':
        message =
        'The account $email has been disabled.\n\nPlease contact support.';
        break;
      case 'too-many-requests':
        message =
        'Too many failed login attempts for $email.\n\nPlease try again in a few minutes.';
        break;
      default:
        message = e.message ?? 'Login failed for $email. Please try again.';
    }

    _showErrorDialog('Login Failed', message);
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    final email = emailCtrl.text.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorDialog(
        'Invalid Email',
        'Please enter a valid email address to reset your password.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSuccessDialog(
        'Password Reset Email Sent',
        'Check your inbox at $email for instructions to reset your password.',
      );
    } on FirebaseAuthException catch (e) {
      String userMessage;
      String title;

      switch (e.code) {
        case 'user-not-found':
          title = 'Account Not Found';
          userMessage =
          'No account found with this email address. Please check the email or create a new account.';
          break;
        case 'invalid-email':
          title = 'Invalid Email';
          userMessage =
          'The email address is not valid. Please enter a valid email address.';
          break;
        case 'too-many-requests':
          title = 'Too Many Requests';
          userMessage =
          'Too many password reset attempts. Please try again later.';
          break;
        default:
          title = 'Reset Failed';
          userMessage =
              e.message ?? 'Failed to send reset email. Please try again.';
      }

      _showErrorDialog(title, userMessage);
    }
  }
}

// Extracted Widgets for Better Performance

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 110),
        Column(
          children: [
            Icon(
              Icons.houseboat,
              size: 64,
              color: Colors.blue, // Using direct color instead of theme lookup
            ),
            SizedBox(height: 8),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sign in to your account',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;

  const _EmailField({
    required this.controller,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined),
        suffixIcon: _ValidationIcon(isValid: isValid),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscure;
  final bool isValid;
  final VoidCallback onToggleObscure;

  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.isValid,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ValidationIcon(isValid: isValid),
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: _getBorderColor(isValid)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }
}

class _ValidationIcon extends StatelessWidget {
  final bool isValid;

  const _ValidationIcon({required this.isValid});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isValid
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : const SizedBox(width: 20),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _ForgotPasswordButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: loading ? null : onPressed,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        backgroundColor: Colors.blue,
      ),
      child: loading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
          : const Text(
        'Login',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }
}

class _RegisterRedirect extends StatelessWidget {
  final bool loading;

  const _RegisterRedirect({required this.loading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey),
        ),
        TextButton(
          onPressed: loading
              ? null
              : () {
            Navigator.pushReplacementNamed(context, RegisterScreen.route);
          },
          child: const Text(
            'Create one',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'By continuing you agree to our Terms and Privacy Policy.',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}

// Helper function outside widget tree
Color _getBorderColor(bool isValid) {
  return isValid ? Colors.green : Colors.grey;
}