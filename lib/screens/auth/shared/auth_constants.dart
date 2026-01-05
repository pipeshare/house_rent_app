// lib/screens/shared/constants.dart
import 'package:flutter/material.dart';

class AuthConstants {
  static const debounceDuration = Duration(milliseconds: 300);
  static const maxFormWidth = 400.0;
  static const formPadding = EdgeInsets.all(24);
  static const borderRadius = BorderRadius.all(Radius.circular(12));

  // Validation constants
  static const minNameLength = 2;
  static const minPasswordLength = 6;
}
