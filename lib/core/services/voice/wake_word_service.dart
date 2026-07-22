import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vosk_flutter/vosk_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io' show Platform;

final wakeWordServiceProvider = Provider<WakeWordService>((ref) {
  return WakeWordService();
});

class WakeWordService {
  bool _isListening = false;
  VoidCallback? _onWakeWordDetected;

  // Vosk (Android/Linux/Windows)
  VoskFlutterPlugin? _vosk;
  Model? _voskModel;
  Recognizer? _voskRecognizer;
  SpeechService? _voskSpeechService;

  // SpeechToText (iOS/MacOS fallback)
  stt.SpeechToText? _speechToText;

  bool get isListening => _isListening;

  Future<void> initialize({required VoidCallback onWakeWordDetected}) async {
    _onWakeWordDetected = onWakeWordDetected;

    if (!kIsWeb && (Platform.isAndroid || Platform.isLinux || Platform.isWindows)) {
      await _initVosk();
    } else {
      await _initSpeechToText();
    }
  }

  Future<void> _initVosk() async {
    try {
      _vosk = VoskFlutterPlugin.instance();
      final modelLoader = ModelLoader();
      final modelPath = await modelLoader.loadFromAssets('assets/models/vosk-model-small-en-us-0.15.zip');
      
      _voskModel = await _vosk!.createModel(modelPath);
      _voskRecognizer = await _vosk!.createRecognizer(
        model: _voskModel!,
        sampleRate: 16000,
        grammar: ['hey', 'inclusion', 'ed', 'opencampus', 'open', 'campus', 'lms', 'porcupine', '[unk]'],
      );
      
      _voskSpeechService = await _vosk!.initSpeechService(_voskRecognizer!);
      
      _voskSpeechService!.onPartial().listen((partial) {
        _checkTranscript(partial);
      });
      
      _voskSpeechService!.onResult().listen((result) {
        _checkTranscript(result);
      });
      
      debugPrint("[WakeWord] Vosk initialized successfully");
    } catch (e) {
      debugPrint("[WakeWord] Failed to initialize Vosk: $e");
    }
  }

  Future<void> _initSpeechToText() async {
    try {
      _speechToText = stt.SpeechToText();
      final available = await _speechToText!.initialize(
        onError: (error) {
          debugPrint("[WakeWord] STT Error: $error");
          // Restart listening on error if we are supposed to be listening
          if (_isListening) {
             Future.delayed(const Duration(seconds: 1), _startSpeechToText);
          }
        },
        onStatus: (status) {
          debugPrint("[WakeWord] STT Status: $status");
          // Restart if it stops automatically
          if (status == 'done' && _isListening) {
             Future.delayed(const Duration(seconds: 1), _startSpeechToText);
          }
        },
      );
      
      if (available) {
        debugPrint("[WakeWord] SpeechToText initialized successfully (iOS fallback)");
      } else {
        debugPrint("[WakeWord] SpeechToText not available on this device");
      }
    } catch (e) {
      debugPrint("[WakeWord] Failed to initialize SpeechToText: $e");
    }
  }

  void _checkTranscript(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('hey inclusion ed') ||
        lower.contains('opencampus') ||
        lower.contains('open campus') ||
        lower.contains('lms') ||
        lower.contains('porcupine')) {
      debugPrint("[WakeWord] Wake word detected!");
      _onWakeWordDetected?.call();
      
      // Stop continuous listening temporarily to avoid overlap
      stopListening();
    }
  }

  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;
    
    if (_voskSpeechService != null) {
      await _voskSpeechService!.start();
      debugPrint("[WakeWord] Vosk started listening");
    } else if (_speechToText != null) {
      _startSpeechToText();
    }
  }

  void _startSpeechToText() {
    _speechToText?.listen(
      onResult: (result) {
        _checkTranscript(result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(hours: 1),
        pauseFor: const Duration(hours: 1),
        partialResults: true,
        cancelOnError: false,
      ),
    );
    debugPrint("[WakeWord] STT started listening");
  }

  Future<void> stopListening() async {
    if (!_isListening) return;
    _isListening = false;
    
    if (_voskSpeechService != null) {
      await _voskSpeechService!.stop();
      debugPrint("[WakeWord] Vosk stopped listening");
    } else if (_speechToText != null) {
      _speechToText!.stop();
      debugPrint("[WakeWord] STT stopped listening");
    }
  }

  Future<void> dispose() async {
    await stopListening();
    _voskSpeechService?.dispose();
    _voskRecognizer?.dispose();
    _voskModel?.dispose();
  }
}
