import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

/// Service for handling file uploads to Supabase Storage
class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final String _bucket =
      'avatars'; // Supabase storage bucket for user avatars

  /// Public getter for bucket name
  static String get bucket => _bucket;

  /// Uploads a file to Supabase Storage under [path]
  /// Returns the public URL of the uploaded file
  static Future<String> uploadFile(File file, String path) async {
    final bytes = await file.readAsBytes();
    try {
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true, // overwrite existing file if present
            ),
          );
    } catch (e) {
      throw Exception('Storage upload error: $e');
    }
    // getPublicUrl returns a String URL
    final publicUrl = _supabase.storage.from(_bucket).getPublicUrl(path);
    return publicUrl;
  }

  /// Downloads image from [url] and uploads to Supabase Storage at [path]
  static Future<String> uploadFromUrl(String url, String path) async {
    // Fetch image bytes
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download avatar image: ${response.statusCode}',
      );
    }
    final bytes = response.bodyBytes;
    try {
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(cacheControl: '3600', upsert: true),
          );
    } catch (e) {
      throw Exception('Storage upload error: $e');
    }
    // For private buckets, use a signed URL (valid for 7 days)
    final signedUrl = await _supabase.storage
        .from(_bucket)
        .createSignedUrl(path, 60 * 60 * 24 * 7);
    return signedUrl;
  }

  /// Deletes a file at [path] from Supabase Storage bucket
  static Future<void> deleteFile(String path) async {
    try {
      await _supabase.storage.from(_bucket).remove([path]);
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Extracts storage path from a public or signed URL
  static String? getPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(_bucket);
      if (bucketIndex < 0) return null;
      return segments.skip(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }
}
