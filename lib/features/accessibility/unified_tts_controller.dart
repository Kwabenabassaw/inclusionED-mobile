import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audio_session/audio_session.dart';

enum TtsEngineType { inbuilt }

class UnifiedTtsController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final String _supabaseFunctionsUrl =
      'https://qczgiqusaftwmdtkvctn.supabase.co/functions/v1';
  final Dio _dio = Dio();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TtsEngineType _activeEngine = TtsEngineType.inbuilt;
  bool _isPlaying = false;

  double _rate = 1.0;
  double _pitch = 1.0;
  double _volume = 1.0;

  Function(int start, int end)? onProgressUpdate;

  // Polly speech marks path
  List<Map<String, dynamic>> _speechMarks = [];
  List<Map<String, dynamic>> _alignmentMap = [];

  // Fallback simulated word timing
  List<_WordSpan> _wordSpans = [];
  Timer? _simulationTimer;

  StreamSubscription? _positionSubscription;
  int _currentSpeakId = 0;

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
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.defaultToSpeaker,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.assistanceAccessibility,
      ),
      androidAudioFocusGainType:
          AndroidAudioFocusGainType.gainTransientMayDuck,
    ));

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _simulationTimer?.cancel();
        _setPlayingState(false);
      }
    });

    // Position stream: used when Polly speech marks are available
    _positionSubscription = _player.positionStream.listen((position) {
      if (_speechMarks.isEmpty || !_isPlaying) return;

      final currentTime = position.inMilliseconds;
      Map<String, dynamic>? currentMark;
      int currentSpeechIdx = -1;

      for (int i = 0; i < _speechMarks.length; i++) {
        if (_speechMarks[i]['time'] <= currentTime) {
          currentMark = _speechMarks[i];
          currentSpeechIdx = i;
        } else {
          break;
        }
      }

      if (currentMark != null && currentSpeechIdx >= 0) {
        int displayStart;
        int displayEnd;

        if (_alignmentMap.isNotEmpty &&
            currentSpeechIdx < _alignmentMap.length) {
          final entry = _alignmentMap[currentSpeechIdx];
          displayStart = entry['displayStart'] as int;
          displayEnd = entry['displayEnd'] as int;
        } else {
          displayStart = currentMark['start'] as int;
          displayEnd = currentMark['end'] as int;
        }

        onProgressUpdate?.call(displayStart, displayEnd);
      }
    });

    notifyListeners();
  }

  Future<void> switchEngine(TtsEngineType newEngine) async {}

  /// Build a word-span list from [text] for client-side timing simulation.
  /// Each span records the char [start]/[end] of each word in the text.
  List<_WordSpan> _buildWordSpans(String text) {
    final spans = <_WordSpan>[];
    final pattern = RegExp(r'\S+');
    for (final m in pattern.allMatches(text)) {
      spans.add(_WordSpan(start: m.start, end: m.end));
    }
    return spans;
  }

  /// Start a timer-based simulation that advances one word at a time,
  /// proportional to the total audio [duration].
  void _startSimulation(Duration duration, List<_WordSpan> words) {
    _simulationTimer?.cancel();
    if (words.isEmpty || duration.inMilliseconds == 0) return;

    final intervalMs = (duration.inMilliseconds / words.length).round();
    int wordIndex = 0;

    _simulationTimer =
        Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!_isPlaying || wordIndex >= words.length) {
        timer.cancel();
        return;
      }
      final span = words[wordIndex];
      onProgressUpdate?.call(span.start, span.end);
      wordIndex++;
    });
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    final speakId = ++_currentSpeakId;
    _simulationTimer?.cancel();
    _setPlayingState(true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (speakId == _currentSpeakId) _setPlayingState(false);
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

      if (speakId != _currentSpeakId) return;

      if (response.statusCode != 200) {
        if (speakId == _currentSpeakId) _setPlayingState(false);
        return;
      }

      final url = response.data['signedUrl'] as String;
      final marksUrl = response.data['marksUrl'] as String?;
      final alignmentUrl = response.data['alignmentUrl'] as String?;

      _speechMarks = [];
      _alignmentMap = [];
      _wordSpans = _buildWordSpans(text);

      // Try to load Polly speech marks
      if (marksUrl != null && marksUrl.isNotEmpty) {
        try {
          final marksResponse = await _dio.get(marksUrl);
          if (marksResponse.statusCode == 200) {
            final String content = marksResponse.data.toString();
            for (final line in content.split('\n')) {
              if (line.trim().isNotEmpty) {
                try {
                  _speechMarks.add(jsonDecode(line));
                } catch (_) {}
              }
            }
            debugPrint(
                'UnifiedTtsController: loaded ${_speechMarks.length} speech marks');
          }
        } catch (e) {
          debugPrint('UnifiedTtsController: speech marks fetch failed: $e');
        }
      }

      // Try to load alignment map
      if (alignmentUrl != null && alignmentUrl.isNotEmpty) {
        try {
          final alignmentResponse = await _dio.get(alignmentUrl);
          if (alignmentResponse.statusCode == 200) {
            final decoded = alignmentResponse.data;
            if (decoded is List) {
              _alignmentMap =
                  decoded.map((e) => e as Map<String, dynamic>).toList();
            } else if (decoded is String) {
              final parsed = jsonDecode(decoded) as List<dynamic>;
              _alignmentMap =
                  parsed.map((e) => e as Map<String, dynamic>).toList();
            }
            debugPrint(
                'UnifiedTtsController: loaded ${_alignmentMap.length} alignment entries');
          }
        } catch (e) {
          debugPrint('UnifiedTtsController: alignment fetch failed: $e');
        }
      }

      if (speakId != _currentSpeakId) return;

      await _player.setUrl(url);
      await _player.setSpeed(_rate);
      await _player.setVolume(_volume);
      await _player.setPitch(_pitch);
      await _player.play();

      // If no speech marks were loaded, fall back to client-side simulation
      if (_speechMarks.isEmpty && onProgressUpdate != null) {
        // Wait a short moment for the player to report its duration
        await Future.delayed(const Duration(milliseconds: 300));
        if (speakId == _currentSpeakId) {
          final duration = _player.duration;
          debugPrint(
              'UnifiedTtsController: no speech marks — simulating with duration $duration');
          if (duration != null && duration.inMilliseconds > 0) {
            _startSimulation(duration, _wordSpans);
          }
        }
      }

      // Wait for natural completion
      await _player.playerStateStream.firstWhere(
        (s) =>
            s.processingState == ProcessingState.completed ||
            (s.processingState == ProcessingState.idle &&
                speakId != _currentSpeakId),
      );

      if (speakId == _currentSpeakId) {
        _simulationTimer?.cancel();
        await _player.stop();
        _setPlayingState(false);
      }
    } catch (e) {
      debugPrint('UnifiedTtsController error: $e');
      if (speakId == _currentSpeakId) {
        _simulationTimer?.cancel();
        _setPlayingState(false);
      }
    }
  }

  Future<void> stop() async {
    _currentSpeakId++;
    _simulationTimer?.cancel();
    await _player.stop();
    _setPlayingState(false);
  }

  void _setPlayingState(bool state) {
    _isPlaying = state;
    if (!state) {
      _simulationTimer?.cancel();
      onProgressUpdate?.call(0, 0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _positionSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }
}

class _WordSpan {
  final int start;
  final int end;
  const _WordSpan({required this.start, required this.end});
}
