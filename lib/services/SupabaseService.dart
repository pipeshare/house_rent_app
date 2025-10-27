import 'dart:typed_data';
import 'package:house_rent_app/core/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final instance = SupabaseService._();
  final _client = Supabase.instance.client;

  /// Uploads bytes to the avatars bucket and returns the public URL (or signed URL per policy).
  Future<String> uploadAvatarBytes({
    required String userId,
    required Uint8List bytes,
    required String fileExt, // e.g. 'png' or 'jpg'
  }) async {
    final path =
        'users/$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage.from(kSupabaseAvatarBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );

    // If bucket is public:
    final publicUrl =
        _client.storage.from(kSupabaseAvatarBucket).getPublicUrl(path);
    return publicUrl;

    // If bucket is private, use signed URL:
    // final signed = await _client.storage.from(kSupabaseAvatarBucket).createSignedUrl(path, 60 * 60 * 24);
    // return signed;
  }
}
