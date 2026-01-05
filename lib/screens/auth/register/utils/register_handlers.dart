import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/services/firestore_service.dart';

class RegisterHandlers {
  static Future<void> handleRegistration({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await _createUserDocument(cred.user!, name, email);
    await cred.user!.updateDisplayName(name);
    await FirestoreService.instance.ensureUserDoc(cred.user!);

    log('✅ User registration successful: $email');
  }

  static Future<void> _createUserDocument(
    User user,
    String name,
    String email,
  ) async {
    final batch = FirebaseFirestore.instance.batch();
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    batch.set(
      userDoc,
      {
        'displayName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    log('✅ User document created in Firestore: ${user.uid}');
  }

  static Future<void> handleRegistrationError(
    BuildContext context,
    dynamic error,
  ) async {
    if (error is FirebaseAuthException) {
      log('❌ Firebase Auth Error: ${error.code} - ${error.message}');
      await _showAuthErrorDialog(context, error);
    } else {
      log('❌ General Error: $error');
      await _showErrorDialog(
        context,
        'Registration Failed',
        'An unexpected error occurred. Please try again.',
      );
    }
  }

  static Future<void> _showAuthErrorDialog(
    BuildContext context,
    FirebaseAuthException error,
  ) async {
    String message;
    final title = 'Registration Failed';

    switch (error.code) {
      case 'email-already-in-use':
        message =
            'This email address is already registered. Please use a different email or try signing in.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid. Please enter a valid email.';
        break;
      case 'operation-not-allowed':
        message =
            'Email/password accounts are not enabled. Please contact support.';
        break;
      case 'weak-password':
        message =
            'The password is too weak. Please choose a stronger password with at least 6 characters.';
        break;
      case 'too-many-requests':
        message =
            'Too many registration attempts. Please try again in a few minutes.';
        break;
      default:
        message = error.message ?? 'Registration failed. Please try again.';
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
}
