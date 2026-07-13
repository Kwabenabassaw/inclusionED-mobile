import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      _isInitialized = await _speechToText.initialize();
    }
  }

  Future<void> startListening({
    required Function(String) onResult,
    required ListenMode listenMode,
  }) async {
    await init();
    if (_isInitialized) {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        listenMode: listenMode,
      );
    }
  }

  Future<void> startCommandListening({required Function(String) onResult}) async {
    await startListening(
      onResult: onResult,
      listenMode: ListenMode.dictation,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
