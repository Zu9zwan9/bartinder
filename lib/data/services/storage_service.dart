import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;


/// Service for handling file uploads to Supabase Storage
class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static final String _bucket = 'avatars'; // Supabase storage bucket for user avatars

  /// Uploads a file to Supabase Storage under [path]
  /// Returns the public URL of the uploaded file
  static Future<String> uploadFile(
    File file,
    String path,
  ) async {
    final bytes = await file.readAsBytes();
    try {
      await _supabase.storage
          .from(_bucket)
          .uploadBinary(path, bytes, fileOptions: FileOptions(
        cacheControl: '3600',
        upsert: false,
      ));
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
      throw Exception('Failed to download avatar image: ${response.statusCode}');
    }
    final bytes = response.bodyBytes;
    try {
      await _supabase.storage.from(_bucket).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );
    } catch (e) {
      throw Exception('Storage upload error: $e');
    }
    // For private buckets, use a signed URL (valid for 7 days)
    final signedUrl = await _supabase.storage.from(_bucket).createSignedUrl(
      path,
      60 * 60 * 24 * 7,
    );
    return signedUrl;
  }
}
