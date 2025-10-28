// lib/core/constants/app_constants.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static const String appName = 'Registration App';
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String profilePicturesBucket = 'profile-pictures';

  static const int maxProfilePictureSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
  ];
}

const Color kPrimaryColor = Color(0xFF0B63FF);
const Color kBackgroundColor = Color(0xFFF6F7FB);
const Color kTitleColor = Color(0xFF0F1724);
const Color kBodyTextColor = Color(0xFF344054);

const double kSpacing = 12.0;
const double kHorizontalPadding = 16.0;

const TextStyle kTitleStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kTitleColor,
);

const TextStyle kBodyStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: kBodyTextColor,
);

const TextStyle kCaptionStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: kBodyTextColor,
);

// // ===== BRAND COLORS =====
// const kPrimaryColor =
//     Color(0xFF22A45D); // Emerald green — energetic, trustworthy
// const kAccentColor = Color(0xFFEF9920); // Warm amber for highlights and buttons
// const kSecondaryColor = Color(0xFF006E5B); // Deep teal for contrast
// const kBackgroundColor = Color(0xFFF7F8FA); // Soft neutral background

// // ===== TEXT COLORS =====
// const kTitleColor = Color(0xFF101213); // Darker for headings
// const kBodyTextColor = Color(0xFF6B6B6B); // Softer body text
// const kHintTextColor = Color(0xFF9E9E9E); // Input hints & placeholders

// ===== SURFACE / CARD COLORS =====
const kCardColor = Color(0xFFFFFFFF); // Standard white card
const kInputFieldColor = Color(0xFFF2F3F5); // Inputs, search fields, filters
const kDividerColor = Color(0xFFE6E8EB); // Thin subtle dividers

// ===== STATUS COLORS =====
const kSuccessColor = Color(0xFF2ECC71); // Success/verified badges
const kErrorColor = Color(0xFFE74C3C); // Error messages / invalid inputs
const kWarningColor = Color(0xFFF39C12); // Warnings / pending states
const kInfoColor = Color(0xFF3498DB); // Information / links

// ===== NEUTRALS =====
const kWhite = Color(0xFFFFFFFF);
const kBlack = Color(0xFF000000);
const kLightGrey = Color(0xFFF5F5F5);
const kDarkGrey = Color(0xFF424242);

// ===== SHADOWS & OVERLAYS =====
const kShadowColor = Color(0x1A000000); // 10% black shadow
const kOverlayColor = Color(0x66000000); // 40% black for modal backgrounds

// ===== GRADIENTS =====
const kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF22A45D), Color(0xFF1E874D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAccentGradient = LinearGradient(
  colors: [Color(0xFFFFB74D), Color(0xFFF57C00)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
