import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/auth/login/utils/login_validators.dart';
import 'package:house_rent_app/services/firestore_service.dart';

class LoginHandlers {
  static Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    await _handleUserDocument(cred.user!, context);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged you in. Enjoy!'),
        ),
      );
      onSuccess();
    }
  }

  static Future<void> _handleUserDocument(
    User user,
    BuildContext context,
  ) async {
    try {
      await FirestoreService.instance.ensureUserDoc(user);
      log('✅ User document created/updated in Firestore');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        log('⚠️ Firestore permission denied - check security rules');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Logged in successfully! However, there was an issue accessing your profile data. '
                'This might be due to security settings.',
              ),
            ),
          );
        }
      } else {
        log('⚠️ Other Firestore error: ${e.code} - ${e.message}');
      }
    } catch (e) {
      log('⚠️ Unexpected error ensuring user doc: $e');
    }
  }

  static Future<void> handleLoginError(
    BuildContext context,
    dynamic error,
    String email,
  ) async {
    if (error is FirebaseAuthException) {
      log('❌ Firebase Auth Error: ${error.code} - ${error.message}');
      await _showAuthErrorDialog(context, error, email);
    } else {
      log('❌ General Error: $error');
      if (context.mounted) {
        await _showErrorDialog(
          context,
          'Login Failed',
          'An unexpected error occurred. Please try again.',
        );
      }
    }
  }

  static Future<void> _showAuthErrorDialog(
    BuildContext context,
    FirebaseAuthException error,
    String email,
  ) async {
    String message;
    final title = 'Login Failed';

    switch (error.code) {
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
        message = error.message ?? 'Login failed for $email. Please try again.';
    }

    await _showErrorDialog(context, title, message);
  }

  static Future<void> handlePasswordReset({
    required BuildContext context,
    required String email,
  }) async {
    if (email.isEmpty || !LoginValidators.isValidEmail(email)) {
      await _showErrorDialog(
        context,
        'Invalid Email',
        'Please enter a valid email address to reset your password.',
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      await _showSuccessDialog(
        context,
        'Password Reset Email Sent',
        'Check your inbox at $email for instructions to reset your password.',
      );
    } on FirebaseAuthException catch (e) {
      await _showPasswordResetError(context, e, email);
    }
  }

  static Future<void> _showPasswordResetError(
    BuildContext context,
    FirebaseAuthException error,
    String email,
  ) async {
    String message;
    String title;

    switch (error.code) {
      case 'user-not-found':
        title = 'Account Not Found';
        message =
            'No account found with this email address. Please check the email or create a new account.';
        break;
      case 'invalid-email':
        title = 'Invalid Email';
        message =
            'The email address is not valid. Please enter a valid email address.';
        break;
      case 'too-many-requests':
        title = 'Too Many Requests';
        message = 'Too many password reset attempts. Please try again later.';
        break;
      default:
        title = 'Reset Failed';
        message =
            error.message ?? 'Failed to send reset email. Please try again.';
    }

    await _showErrorDialog(context, title, message);
  }

  static Future<void> _showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return;

    await showDialog(
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

  static Future<void> _showSuccessDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    if (!context.mounted) return;

    await showDialog(
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
}
