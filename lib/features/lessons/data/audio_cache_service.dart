import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioCacheServiceProvider = Provider<AudioCacheService>((ref) {
  return AudioCacheService();
});

class AudioCacheService {
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Checks if a file is already cached and returns its local path, or null if not cached.
  Future<String?> getCachedFilePath(String cacheKey) async {
    final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
    return fileInfo?.file.path;
  }

  /// Gets the local file path for a cached audio file, or downloads it if it isn't cached.
  Future<String> getCachedAudioPath(String url, String cacheKey) async {
    final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
    if (fileInfo != null) {
      return fileInfo.file.path;
    }

    final file = await _cacheManager.downloadFile(url, key: cacheKey);
    return file.file.path;
  }

  /// Downloads and reads the speech marks JSON file.
  Future<String> getCachedSpeechMarks(String url, String cacheKey) async {
    final jsonKey = '${cacheKey}_json';
    final fileInfo = await _cacheManager.getFileFromCache(jsonKey);
    if (fileInfo != null) {
      return await fileInfo.file.readAsString();
    }

    final file = await _cacheManager.downloadFile(url, key: jsonKey);
    return await file.file.readAsString();
  }

  /// Gets the local cached JSON string if available, otherwise returns null.
  Future<String?> getCachedSpeechMarksString(String cacheKey) async {
    final jsonKey = '${cacheKey}_json';
    final fileInfo = await _cacheManager.getFileFromCache(jsonKey);
    if (fileInfo != null) {
      return await fileInfo.file.readAsString();
    }
    return null;
  }

  /// Downloads and reads the alignment map JSON file.
  Future<String> getCachedAlignment(String url, String cacheKey) async {
    final alignKey = '${cacheKey}_align';
    final fileInfo = await _cacheManager.getFileFromCache(alignKey);
    if (fileInfo != null) {
      return await fileInfo.file.readAsString();
    }
    final file = await _cacheManager.downloadFile(url, key: alignKey);
    return await file.file.readAsString();
  }

  /// Returns cached alignment map JSON string if available, otherwise null.
  Future<String?> getCachedAlignmentString(String cacheKey) async {
    final alignKey = '${cacheKey}_align';
    final fileInfo = await _cacheManager.getFileFromCache(alignKey);
    if (fileInfo != null) {
      return await fileInfo.file.readAsString();
    }
    return null;
  }

  /// Removes a file from the cache
  Future<void> removeAudio(String cacheKey) async {
    await _cacheManager.removeFile(cacheKey);
  }
}
