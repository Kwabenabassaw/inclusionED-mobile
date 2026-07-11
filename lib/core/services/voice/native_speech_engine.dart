import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'speech_engine.dart';

class NativeSpeechEngine implements SpeechEngine {
  final SpeechToText _stt = SpeechToText();
  final _controller = StreamController<String>.broadcast();
  final _interimController = StreamController<String>.broadcast();
  String _lastWords = '';
  bool _hasEmitted = false;
  
  @override
  Stream<String> get transcriptStream => _controller.stream;
  
  @override
  Stream<String> get interimTranscriptStream => _interimController.stream;
  
  @override
  bool get isRealTimeStreaming => true;

  @override
  Future<void> initialize() async {
    await _stt.initialize();
  }

  @override
  Future<void> startListening() async {
    if (!_stt.isAvailable) {
      await initialize();
    }
    _lastWords = '';
    _hasEmitted = false;
    await _stt.listen(onResult: (result) {
      if (result.recognizedWords.isNotEmpty) {
        _lastWords = result.recognizedWords;
        _interimController.add(result.recognizedWords);
        // Only emit if the STT engine has detected silence (final result)
        // and we haven't already emitted.
        if (result.finalResult && !_hasEmitted) {
          _hasEmitted = true;
          _controller.add(result.recognizedWords);
        }
      }
    });
  }

  @override
  Future<void> stopListening() async {
    await _stt.stop();
    // If stopped manually before a final result was emitted, emit what we have.
    if (!_hasEmitted && _lastWords.isNotEmpty) {
      _hasEmitted = true;
      _controller.add(_lastWords);
    }
  }
  
  @override
  void dispose() {
    _stt.stop();
    _controller.close();
    _interimController.close();
  }
}
