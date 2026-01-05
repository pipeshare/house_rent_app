import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:house_rent_app/services/nominatim_service.dart';

class HomeHelpers {
  static Stream<QuerySnapshot> getPropertiesStream({required String category}) {
    final firestore = FirebaseFirestore.instance;

    return category == 'All'
        ? firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots()
        : firestore
            .collection('posts')
            .where('category', isEqualTo: category)
            .snapshots();
  }

  static void toggleSheet(DraggableScrollableController controller) {
    if (controller.size > 0.5) {
      // Switch to map view
      controller.animateTo(
        0.04,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Switch to list view
      controller.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  static LatLng calculateMapCenter(List<QueryDocumentSnapshot> properties) {
    if (properties.isEmpty) {
      return const LatLng(-15.3875, 28.3228); // Default Lusaka center
    }

    double totalLat = 0;
    double totalLng = 0;
    int validProperties = 0;

    for (final doc in properties) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        totalLat += lat;
        totalLng += lng;
        validProperties++;
      }
    }

    if (validProperties > 0) {
      return LatLng(totalLat / validProperties, totalLng / validProperties);
    }

    return const LatLng(-15.3875, 28.3228);
  }

  static String getCurrencySymbol(String currency) {
    switch (currency.toLowerCase()) {
      case "usd":
        return '\$';
      case "zar":
        return 'R';
      case "gbp":
        return '£';
      case "eur":
        return '€';
      default:
        return 'K';
    }
  }

  static Future<void> moveToCurrentLocation(MapController mapController) async {
    final location = await Location().getLocation();
    mapController.move(
      LatLng(location.latitude!, location.longitude!),
      15.0,
    );
  }

  static Future<List<Map<String, dynamic>>> searchLocations(
    String query, {
    String countryCode = 'zm',
  }) async {
    try {
      return await NominatimService.search(
        query: query,
        countryCode: countryCode,
      );
    } catch (e) {
      return [];
    }
  }

  static IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'apartment':
        return Icons.apartment_rounded;
      case 'house':
        return Icons.house_rounded;
      case 'business_center':
        return Icons.business_center_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      case 'warehouse':
        return Icons.warehouse_rounded;
      case 'terrain':
        return Icons.terrain_rounded;
      case 'night_shelter':
        return Icons.night_shelter_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'store_mall_directory':
        return Icons.store_mall_directory_rounded;
      case 'factory':
        return Icons.factory_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static IconData getSuggestionIcon(String type) {
    switch (type) {
      case 'city':
        return Icons.location_city;
      case 'area':
      case 'suburb':
        return Icons.place;
      case 'village':
        return Icons.house;
      case 'region':
        return Icons.map;
      default:
        return Icons.location_on;
    }
  }

  static String formatAddress(Map<String, dynamic> address) {
    final parts = [];

    if (address['city'] != null) parts.add(address['city']);
    if (address['town'] != null) parts.add(address['town']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['country'] != null) parts.add(address['country']);

    return parts.join(', ');
  }

  static String formatDisplayName(
      String displayName, Map<String, dynamic> address) {
    final city = address['city'] ?? address['town'];
    final suburb = address['suburb'] ?? address['neighbourhood'];
    final road = address['road'];

    if (suburb != null && city != null) {
      return '$suburb, $city';
    } else if (road != null && city != null) {
      return '$road, $city';
    }

    return displayName.split(',').first;
  }
}
