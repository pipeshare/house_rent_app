import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/models/Professional.dart';

class ProfessionalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Professional>> loadProfessionals() async {
    try {
      final snapshot = await _firestore.collection('professionals').get();

      final loadedProfessionals = snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert the specialty string to enum safely
        final specialtyStr = (data['specialty'] ?? '').toString().toLowerCase();
        final specialty = ProfessionalSpecialty.values.firstWhere(
          (e) => e.name.toLowerCase() == specialtyStr,
          orElse: () => ProfessionalSpecialty.agent,
        );

        return Professional(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          company: data['company'] ?? 'Unknown Company',
          specialty: specialty,
          rating: (data['rating'] ?? 0).toDouble(),
          verified: data['verified'] ?? false,
          imageUrl: data['imageUrl'] ?? '',
          yearsExperience: data['yearsExperience'] ?? 0,
          phone: data['phone'] ?? '',
        );
      }).toList();

      return loadedProfessionals;
    } catch (e) {
      debugPrint('Error loading professionals: $e');
      return [];
    }
  }

  static Stream<List<Professional>> watchProfessionals() {
    return _firestore.collection('professionals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final specialtyStr = (data['specialty'] ?? '').toString().toLowerCase();
        final specialty = ProfessionalSpecialty.values.firstWhere(
          (e) => e.name.toLowerCase() == specialtyStr,
          orElse: () => ProfessionalSpecialty.agent,
        );

        return Professional(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          company: data['company'] ?? 'Unknown Company',
          specialty: specialty,
          rating: (data['rating'] ?? 0).toDouble(),
          verified: data['verified'] ?? false,
          imageUrl: data['imageUrl'] ?? '',
          yearsExperience: data['yearsExperience'] ?? 0,
          phone: data['phone'] ?? '',
        );
      }).toList();
    });
  }

  static Future<void> addProfessional({
    required String name,
    required String company,
    required ProfessionalSpecialty specialty,
    required double rating,
    required String imageUrl,
    required int yearsExperience,
    required String phone,
  }) async {
    await _firestore.collection('professionals').add({
      'name': name,
      'company': company,
      'specialty': specialty.name,
      'rating': rating,
      'verified': false,
      'imageUrl': imageUrl,
      'yearsExperience': yearsExperience,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
