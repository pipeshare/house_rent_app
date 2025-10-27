import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Upload images to Supabase Storage
  Future<List<String>> uploadImagesToSupabase(List<String> imagePaths) async {
    final List<String> imageUrls = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final String fileName =
            'properties/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        // Upload to Supabase Storage
        final response = await _supabase.storage.from('property_images').upload(
            fileName, (await File(imagePaths[i]).readAsBytes()) as File);

        // Get public URL
        final String publicUrl =
            _supabase.storage.from('property_images').getPublicUrl(fileName);

        imageUrls.add(publicUrl);
      } catch (e) {
        print('Error uploading image to Supabase: $e');
        rethrow;
      }
    }

    return imageUrls;
  }

  // Upload images to Firebase Storage (alternative)
  Future<List<String>> uploadImagesToFirebase(List<String> imagePaths) async {
    final List<String> imageUrls = [];

    for (int i = 0; i < imagePaths.length; i++) {
      try {
        final String fileName =
            'properties/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference storageRef = _storage.ref().child(fileName);

        // Upload the file
        await storageRef.putFile(File(imagePaths[i]));

        // Get download URL
        final String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        print('Error uploading image to Firebase: $e');
        rethrow;
      }
    }

    return imageUrls;
  }

  // Create post in Firestore
  Future<void> createPost({
    required String category,
    required String title,
    required String description,
    required String location,
    required String price,
    required List<String> imageUrls,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final postData = {
        'id': _firestore.collection('posts').doc().id,
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? 'Anonymous',
        'category': category,
        'title': title,
        'description': description,
        'location': location,
        'price':
            double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
        'priceFormatted': 'ZMW $price',
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active', // active, pending, sold, rented
        'views': 0,
        'saves': 0,
        'isVerified': false,
      };

      await _firestore
          .collection('posts')
          .doc(postData['id'] as String?)
          .set(postData);

      print('✅ Post created successfully with ID: ${postData['id']}');
    } catch (e) {
      print('❌ Error creating post: $e');
      rethrow;
    }
  }

  // Get user's posts
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update post
  Future<void> updatePost(String postId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('posts').doc(postId).update(updates);
    } catch (e) {
      print('❌ Error updating post: $e');
      rethrow;
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('❌ Error deleting post: $e');
      rethrow;
    }
  }
}
