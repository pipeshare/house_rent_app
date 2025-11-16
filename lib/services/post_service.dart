import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> postProperty({
    required BuildContext context,
    required String category,
    required String title,
    required String description,
    required String location,
    required String price,
    required List<String> photos,
    required String userId,
  }) async {
    try {
      // 1) Upload photos
      final uploadedUrls = await _uploadPhotosToSupabase(photos);

      // 2) Save to Firestore
      await _savePropertyToFirestore(
        category: category,
        title: title,
        description: description,
        location: location,
        price: price,
        photoUrls: uploadedUrls,
        userId: userId,
      );

      _showToast(context, "Property posted successfully!");

      Navigator.of(context).pop();
    } catch (e) {
      _showToast(context, "Error posting property: $e");
    }
  }

  Future<List<String>> _uploadPhotosToSupabase(List<String> photos) async {
    if (photos.isEmpty) return [];

    List<String> uploadedUrls = [];

    for (int i = 0; i < photos.length; i++) {
      final filePath = photos[i];
      final file = File(filePath);

      if (!await file.exists()) {
        debugPrint("⚠️ File not found: $filePath");
        continue;
      }

      final ext = _getFileExtension(filePath);
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}_$i.$ext';
      final storagePath = 'posts/$fileName';

      await _supabase.storage
          .from(kSupabaseAvatarBucket)
          .upload(storagePath, file);

      final publicUrl = _supabase.storage
          .from(kSupabaseAvatarBucket)
          .getPublicUrl(storagePath);

      uploadedUrls.add(publicUrl);
    }

    return uploadedUrls;
  }

  String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    return parts.length > 1 ? parts.last : 'jpg';
  }

  Future<void> _savePropertyToFirestore({
    required String category,
    required String title,
    required String description,
    required String location,
    required String price,
    required List<String> photoUrls,
    required String userId,
  }) async {
    await _firestore.collection('properties').add({
      'category': category,
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'price': double.tryParse(price) ?? 0.0,
      'photos': photoUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'status': 'active',
      'views': 0,
      'likes': 0,
    });
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
