import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum TtsEngineType { inbuilt }

class UnifiedTtsController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final String _supabaseFunctionsUrl = 'https://qczgiqusaftwmdtkvctn.supabase.co/functions/v1';
  final Dio _dio = Dio();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final TtsEngineType _activeEngine = TtsEngineType.inbuilt;
  bool _isPlaying = false;
  
  double _rate = 1.0;
  double _pitch = 1.0;
  double _volume = 1.0;

  Function(int start, int end)? onProgressUpdate;

  TtsEngineType get activeEngine => _activeEngine;
  bool get isPlaying => _isPlaying;
  double get rate => _rate;
  double get pitch => _pitch;
  double get volume => _volume;

  Future<void> setRate(double value) async {
    _rate = value;
    await _player.setSpeed(value);
    notifyListeners();
  }

  Future<void> setPitch(double value) async {
    _pitch = value;
    await _player.setPitch(value);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    await _player.setVolume(value);
    notifyListeners();
  }

  Future<void> initialize() async {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _setPlayingState(false);
      }
    });
    notifyListeners();
  }

  Future<void> switchEngine(TtsEngineType newEngine) async {
    return;
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    
    _setPlayingState(true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _setPlayingState(false);
        return;
      }
      final idToken = await user.getIdToken();
      final response = await _dio.post(
        '$_supabaseFunctionsUrl/generate-lesson-audio',
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'lessonId': 'unified_tts_${text.hashCode}',
          'text': text.length > 3000 ? text.substring(0, 3000) : text,
          'voice': 'Joanna',
        },
      );

      if (response.statusCode == 200) {
        final url = response.data['signedUrl'] as String;
        await _player.setUrl(url);
        await _player.setSpeed(_rate);
        await _player.setVolume(_volume);
        await _player.setPitch(_pitch);
        await _player.play();
      } else {
        _setPlayingState(false);
      }
    } catch (e) {
      debugPrint('UnifiedTtsController error: $e');
      _setPlayingState(false);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _setPlayingState(false);
  }

  void _setPlayingState(bool state) {
    _isPlaying = state;
    if (!state && onProgressUpdate != null) {
      onProgressUpdate!(0, 0); 
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
