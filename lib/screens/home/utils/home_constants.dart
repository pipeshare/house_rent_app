import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class HomeConstants {
  // Animation constants
  static const animationDuration = Duration(milliseconds: 300);
  static const fastAnimationDuration = Duration(milliseconds: 200);
  static const debounceDuration = Duration(milliseconds: 500);

  // Layout constants
  static const double maxSheetSize = 1.0;
  static const double minSheetSize = 0.04;
  static const double mapZoomLevel = 13.0;
  static const double selectedMapZoomLevel = 14.0;

  // Padding constants
  static const screenPadding = EdgeInsets.all(24);
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 20);
  static const cardPadding = EdgeInsets.all(12);

  // Sizing constants
  static const double searchBarHeight = 40.0;
  static const double categoryTabHeight = 88.0;
  static const double professionalCardSize = 70.0;
  static const double mapMarkerSize = 30.0;

  // Default coordinates (Lusaka, Zambia)
  static const defaultLatitude = -15.3875;
  static const defaultLongitude = 28.3228;

  // Popular locations in Zambia
  static const Map<String, LatLng> popularLocations = {
    'Lusaka': LatLng(-15.3875, 28.3228),
    'Kitwe': LatLng(-12.8230, 28.1939),
    'Ndola': LatLng(-12.9586, 28.6366),
    'Livingstone': LatLng(-17.8532, 25.8674),
    'Chipata': LatLng(-13.6393, 32.6459),
    'Kabwe': LatLng(-14.4431, 28.4531),
  };

  // Validation constants
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
  static const int maxSearchResults = 10;

  // Cache constants
  static const int imageCacheDuration = 30; // days
  static const int maxCacheSize = 100; // MB

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: Colors.grey,
    fontSize: 14,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.green;
  static const Color accentColor = Colors.orange;
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
}
