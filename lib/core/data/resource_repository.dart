import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final resourceRepositoryProvider = Provider((ref) => ResourceRepository());

class ResourceRepository {
  final _supabase = Supabase.instance.client;
  final _cacheManager = DefaultCacheManager();

  /// Gets a signed URL for private resources
  Future<String> getSignedUrl(String storagePath, {String bucket = 'inclusive', int expiresIn = 86400}) async {
    // If it's a full URL already (e.g. legacy or public image), return as is
    if (storagePath.startsWith('http')) return storagePath;

    final response = await _supabase.storage
        .from(bucket)
        .createSignedUrl(storagePath, expiresIn);
        
    return response;
  }

  /// Gets the public URL for public assets like profile pictures or course thumbnails
  String getPublicUrl(String storagePath, {String bucket = 'inclusive'}) {
    if (storagePath.startsWith('http')) return storagePath;
    
    return _supabase.storage.from(bucket).getPublicUrl(storagePath);
  }

  /// Downloads and caches a file for offline usage
  Future<File> downloadOfflineResource(String storagePath, {String bucket = 'inclusive'}) async {
    final url = await getSignedUrl(storagePath, bucket: bucket);
    
    // Check if it's already in cache using the raw storagePath as the consistent key
    final fileInfo = await _cacheManager.getFileFromCache(storagePath);
    if (fileInfo != null) {
      return fileInfo.file;
    }

    // Otherwise download it using the signed URL, but cache it under the consistent storagePath key
    return await _cacheManager.getSingleFile(url, key: storagePath);
  }

  /// Removes a file from cache
  Future<void> removeOfflineResource(String storagePath, {String bucket = 'inclusive'}) async {
    await _cacheManager.removeFile(storagePath);
  }
}
