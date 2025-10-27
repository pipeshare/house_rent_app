// lib/core/constants/app_constants.dart
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
