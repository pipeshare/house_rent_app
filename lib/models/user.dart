// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User data model representing application user profile
/// Follows clean architecture principles and immutable design patterns
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.isEmailVerified,
  });

  /// Creates an empty User instance
  factory User.empty() => User(
        id: '',
        email: '',
        fullName: '',
        profileImageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isEmailVerified: false,
      );

  /// Creates User from Firestore DocumentSnapshot with proper error handling
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data();
      if (data == null) {
        throw const FormatException('Firestore document data is null');
      }

      // Validate required fields
      _validateFirestoreData(data, doc.id);

      final createdAt = _parseTimestamp(data['createdAt']);
      final updatedAt = _parseTimestamp(data['updatedAt']) ?? createdAt;

      return User(
        id: doc.id,
        email: data['email'] as String,
        fullName: data['fullName'] as String,
        profileImageUrl: data['profileImageUrl'] as String?,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      );
    } on FormatException catch (e) {
      throw FormatException(
          'Failed to parse User from Firestore: ${e.message}');
    } catch (e) {
      throw FormatException(
          'Unexpected error creating User from Firestore: $e');
    }
  }

  /// Validates required Firestore data fields
  static void _validateFirestoreData(Map<String, dynamic> data, String docId) {
    if (data['email'] == null) {
      throw FormatException('Email is required for user $docId');
    }
    if (data['fullName'] == null) {
      throw FormatException('Full name is required for user $docId');
    }
    if (data['createdAt'] == null) {
      throw FormatException('CreatedAt is required for user $docId');
    }
  }

  /// Parses timestamp with null safety
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) {
      throw const FormatException('Timestamp cannot be null');
    }

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      throw FormatException(
          'Invalid timestamp format: ${timestamp.runtimeType}');
    }
  }

  /// Converts to Firestore-compatible map with server timestamp for updatedAt
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Converts to simple Map for local storage or caching
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isEmailVerified': isEmailVerified,
    };
  }

  /// Creates User from Map with validation
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      return User(
        id: map['id'] as String,
        email: map['email'] as String,
        fullName: map['fullName'] as String,
        profileImageUrl: map['profileImageUrl'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
        isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      );
    } catch (e) {
      throw FormatException('Failed to create User from Map: $e');
    }
  }

  /// Creates a copy with updated fields (immutable update pattern)
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  /// Validates if the user model has valid data
  bool get isValid {
    return id.isNotEmpty &&
        email.isNotEmpty &&
        fullName.isNotEmpty &&
        createdAt.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  /// Convenience getter to check if user is empty
  bool get isEmpty => this == User.empty();

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, '
        'profileImageUrl: $profileImageUrl, createdAt: $createdAt, '
        'updatedAt: $updatedAt, isEmailVerified: $isEmailVerified)';
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        profileImageUrl,
        createdAt,
        updatedAt,
        isEmailVerified,
      ];
}

/// Extension for Firebase User conversion
extension FirebaseUserExtension on User {
  /// Converts Firebase User to User
  User toUser({
    required uuid,
    required String fullName,
    String? profileImageUrl,
    bool isEmailVerified = false,
  }) {
    return User(
      id: uuid,
      email: email,
      fullName: fullName,
      profileImageUrl: profileImageUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isEmailVerified: isEmailVerified,
    );
  }
}
