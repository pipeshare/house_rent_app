import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/models/DataModels.dart';
import '../utils/home_helpers.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Category>> loadCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();

      final loadedCategories = snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          data['name'] ?? 'Unknown',
          HomeHelpers.getIconFromString(data['icon'] ?? 'apartment'),
        );
      }).toList();

      return loadedCategories;
    } catch (e) {
      debugPrint('Error loading categories: $e');
      return []; // Return empty list on error
    }
  }

  static Stream<List<Category>> watchCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          data['name'] ?? 'Unknown',
          HomeHelpers.getIconFromString(data['icon'] ?? 'apartment'),
        );
      }).toList();
    });
  }

  static Future<void> addCategory(String name, String iconName) async {
    await _firestore.collection('categories').add({
      'name': name,
      'icon': iconName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
