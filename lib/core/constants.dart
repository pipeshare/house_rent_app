import 'package:flutter/material.dart';

// ===== BRAND COLORS =====
const kPrimaryColor =
    Color(0xFF22A45D); // Emerald green — energetic, trustworthy
const kAccentColor = Color(0xFFEF9920); // Warm amber for highlights and buttons
const kSecondaryColor = Color(0xFF006E5B); // Deep teal for contrast
const kBackgroundColor = Color(0xFFF7F8FA); // Soft neutral background

// ===== TEXT COLORS =====
const kTitleColor = Color(0xFF101213); // Darker for headings
const kBodyTextColor = Color(0xFF6B6B6B); // Softer body text
const kHintTextColor = Color(0xFF9E9E9E); // Input hints & placeholders

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

// TODO: fill with your real values (or use --dart-define in prod).
const String kSupabaseUrl = 'https://fejvhkscfibsrcixorwd.supabase.co';
const String kSupabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZlanZoa3NjZmlic3JjaXhvcndkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MDc5MTAsImV4cCI6MjA3NjQ4MzkxMH0.vbVe-hOuk_5GsB-1bzPBvFMhkVI8fvIgwlbiL-3a4Do';
const String kSupabaseAvatarBucket = 'users';
