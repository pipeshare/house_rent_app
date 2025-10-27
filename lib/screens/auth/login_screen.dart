import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/services/FirestoreService.dart';
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

  @override
  void initState() {
    super.initState();
    emailCtrl.addListener(_validateEmail);
    passCtrl.addListener(_validatePassword);
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
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
                  // Header
                  const SizedBox(height: 110),
                  Column(
                    children: [
                      Icon(
                        Icons.houseboat,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome Back',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      suffixIcon: _buildValidationIcon(_isEmailValid),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide:
                            BorderSide(color: _getBorderColor(_isEmailValid)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: passCtrl,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildValidationIcon(_isPasswordValid),
                          IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: _getBorderColor(_isPasswordValid)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: loading ? null : _resetPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign In Button
                  FilledButton(
                    onPressed: loading ? null : _login,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                            'Sign In',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register redirect
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: loading
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(
                                    context, RegisterScreen.route);
                              },
                        child: Text(
                          'Create one',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text(
                    'By continuing you agree to our Terms and Privacy Policy.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _validateEmail() {
    final email = emailCtrl.text.trim();
    setState(() {
      _isEmailValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = passCtrl.text.isNotEmpty;
    });
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
          // Continue login anyway - the user is authenticated
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
          // Continue login anyway
        }
      } catch (e) {
        log('⚠️ Unexpected error ensuring user doc: $e');
        // Continue login anyway
      }

      // Success - navigate to home
      if (mounted) {
        log('🚀 Navigating to home screen...');
        // Just let the AuthWrapper handle the navigation automatically
        // The auth state change will trigger the home screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged you in. Enjoy!'),
          ),
        );
        // AuthWrapper();
      }
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      _handleAuthError(e, email);
    } catch (e) {
      log('❌ General Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
        ),
      );
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

  Color _getBorderColor(bool isValid) {
    if (!isValid) return Colors.grey.shade400;
    return isValid ? Colors.green : Colors.orange;
  }

  Widget _buildValidationIcon(bool isValid) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isValid
          ? Icon(Icons.check_circle,
              color: Colors.green, size: 20, key: UniqueKey())
          : const SizedBox(width: 20),
    );
  }
}
