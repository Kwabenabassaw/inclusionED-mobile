import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ttsRepositoryProvider = Provider<TtsRepository>((ref) {
  return TtsRepository(
    dio: Dio(),
    auth: FirebaseAuth.instance,
  );
});

class TtsRepository {
  final Dio _dio;
  final FirebaseAuth _auth;
  // TODO: Move to env variables
  final String _supabaseFunctionsUrl = 'https://qczgiqusaftwmdtkvctn.supabase.co/functions/v1';

  TtsRepository({required this._dio, required this._auth});

  Future<({String audioUrl, String marksUrl, String alignmentUrl})> getLessonAudioUrl({
    required String lessonId,
    required String text,
    required String voice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken();

    try {
      final response = await _dio.post(
        '$_supabaseFunctionsUrl/generate-lesson-audio',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'lessonId': lessonId,
          'text': text,
          'voice': voice,
        },
      );

      if (response.statusCode == 200) {
        return (
          audioUrl: response.data['signedUrl'] as String,
          marksUrl: response.data['marksUrl'] as String,
          alignmentUrl: response.data['alignmentUrl'] as String,
        );
      } else {
        throw Exception('Failed to generate audio: ${response.data}');
      }
    } catch (e) {
      throw Exception('Error generating audio: $e');
    }
  }
}
