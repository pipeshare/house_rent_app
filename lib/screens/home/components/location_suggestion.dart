import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Represents a location suggestion from Nominatim API
class LocationSuggestion {
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final Map<String, dynamic> address;
  final String? placeId;
  final String? osmType;
  final String? osmId;

  LocationSuggestion({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeId,
    this.osmType,
    this.osmId,
  });

  /// Creates a LocationSuggestion from Nominatim API response
  factory LocationSuggestion.fromNominatim(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['display_name']?.toString() ?? '',
      type: _extractLocationType(json),
      latitude: _parseDouble(json['lat']),
      longitude: _parseDouble(json['lon']),
      address: Map<String, dynamic>.from(json['address'] ?? {}),
      placeId: json['place_id']?.toString(),
      osmType: json['osm_type']?.toString(),
      osmId: json['osm_id']?.toString(),
    );
  }

  @override
  String toString() => 'LocationSuggestion(name: $name, type: $type)';

  /// Extract location type from Nominatim response
  static String _extractLocationType(Map<String, dynamic> json) {
    final category = json['category']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';

    if (category.isNotEmpty && type.isNotEmpty) {
      return '$category:$type';
    }
    return category.isNotEmpty ? category : type;
  }

  /// Parse double from string with error handling
  static double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }
}
