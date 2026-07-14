import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:opencampus_lms/core/services/intent/command_interpreter.dart';
import 'package:opencampus_lms/core/services/voice/speech_engine.dart';
import 'package:opencampus_lms/core/services/voice/voice_command_state.dart';
import 'package:record/record.dart';

/// Data class that represents the full state snapshot of the voice overlay.
class VoiceOverlayData {
  final VoiceCommandState state;

  /// The raw transcript text produced by the speech engine (if any).
  final String transcript;

  /// Resolved intent map on success; null on failure or before processing.
  final Map<String, dynamic>? resolvedIntent;

  /// True when the last processing attempt produced no usable intent.
  final bool didFail;

  const VoiceOverlayData({
    this.state = VoiceCommandState.idle,
    this.transcript = '',
    this.resolvedIntent,
    this.didFail = false,
  });

  VoiceOverlayData copyWith({
    VoiceCommandState? state,
    String? transcript,
    Map<String, dynamic>? resolvedIntent,
    bool? didFail,
    bool clearIntent = false,
  }) {
    return VoiceOverlayData(
      state: state ?? this.state,
      transcript: transcript ?? this.transcript,
      resolvedIntent: clearIntent ? null : resolvedIntent ?? this.resolvedIntent,
      didFail: didFail ?? this.didFail,
    );
  }
}

/// State machine controller for the Google Assistant-style voice overlay.
///
/// Owns the full idle → listening → processing → result → idle lifecycle.
/// All state transitions are guarded against concurrent sessions via
/// [_isActive].
class VoiceOverlayController extends Notifier<VoiceOverlayData> {
  // ─── Dependencies (injected via build()) ──────────────────────────────────
  late SpeechEngine _engine;
  late CommandInterpreter _parser;

  // ─── Internal ────────────────────────────────────────────────────────────
  /// Prevents concurrent recording/processing sessions when the FAB is
  /// tapped rapidly.
  bool _isActive = false;

  StreamSubscription<String>? _transcriptSub;
  StreamSubscription<String>? _interimSub;

  /// Silence-detection timer used only for [WhisperSpeechEngine]
  /// (isRealTimeStreaming == false). Fires after 1.8 s of sustained silence.
  Timer? _silenceTimer;

  /// Used only for amplitude polling during Whisper recording.
  StreamSubscription<Amplitude>? _amplitudeSub;

  /// On-device TTS for the earcon — uses flutter_tts directly to avoid the
  /// AWS Polly network round-trip in UnifiedTtsController.
  final FlutterTts _earconTts = FlutterTts();

  @override
  VoiceOverlayData build() {
    ref.onDispose(_cleanup);
    return const VoiceOverlayData();
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Whether a recording or processing session is currently active.
  /// Used by the FAB tap handler to reject rapid double-taps.
  bool get isActive => _isActive;

  /// [idle → listening]
  ///
  /// Triggered by the FAB tap. Guards against concurrent sessions.
  Future<void> startListening({
    required SpeechEngine engine,
    required CommandInterpreter parser,
  }) async {
    if (_isActive) {
      debugPrint('[VoiceCmd] startListening called while already active — ignored.');
      return;
    }

    _engine = engine;
    _parser = parser;
    _isActive = true;

    state = const VoiceOverlayData(state: VoiceCommandState.listening);

    try {
      await _engine.initialize();

      // Subscribe to transcript stream BEFORE starting to avoid missing events.
      _transcriptSub?.cancel();
      _transcriptSub = _engine.transcriptStream.listen(
        _onTranscript,
        onError: _onTranscriptError,
      );

      _interimSub?.cancel();
      _interimSub = _engine.interimTranscriptStream.listen((text) {
        if (state.state == VoiceCommandState.listening) {
          state = state.copyWith(transcript: text);
        }
      });

      await _engine.startListening();

      // For batch engines (Whisper) we drive silence detection ourselves via
      // amplitude polling. Native STT fires finalResult automatically via its
      // own VAD; no timer needed.
      if (!_engine.isRealTimeStreaming) {
        _startAmplitudeSilenceDetection();
      }
    } catch (e) {
      debugPrint('[VoiceCmd] startListening error: $e');
      _resetToIdle();
      rethrow;
    }
  }

  /// [listening → processing]
  ///
  /// Called either by the silence timer expiry OR by a manual "tap-to-stop"
  /// tap in the overlay. Safe to call multiple times — subsequent calls are
  /// no-ops once processing has started.
  Future<void> stopRecording() async {
    if (state.state != VoiceCommandState.listening) return;

    _cancelSilenceDetection();

    debugPrint('[VoiceCmd] recording_stopped: ${DateTime.now().toIso8601String()}');

    state = state.copyWith(state: VoiceCommandState.processing);

    // Play the on-device earcon so blind users hear the transition
    // immediately, without waiting for the Polly network call.
    await _playEarcon();

    try {
      // For batch engines, stopListening() triggers transcription internally
      // and emits a result on transcriptStream. The _onTranscript callback
      // takes over from here.
      // For real-time engines (native STT), the transcript has ALREADY been
      // received via _onTranscript before this is called — stopListening just
      // cleans up the session.
      await _engine.stopListening();
    } catch (e) {
      debugPrint('[VoiceCmd] stopListening error: $e');
      _handleFailure();
    }
  }

  /// [any → idle]
  ///
  /// Called when the user taps Cancel or taps outside the modal barrier.
  Future<void> cancel() async {
    debugPrint('[VoiceCmd] cancel() called from state: ${state.state}');
    _cancelSilenceDetection();
    _transcriptSub?.cancel();
    _transcriptSub = null;
    _interimSub?.cancel();
    _interimSub = null;

    try {
      if (state.state == VoiceCommandState.listening) {
        await _engine.stopListening();
      }
    } catch (_) {}

    _resetToIdle();
  }

  /// Resets to idle after the overlay has auto-dismissed following a success.
  void resetToIdle() => _resetToIdle();

  // ─── Private state machine handlers ─────────────────────────────────────

  /// Called by the transcript stream when the engine produces a result.
  /// [processing → result]
  Future<void> _onTranscript(String transcript) async {
    // Guard: only process if we're in listening or processing state.
    if (state.state != VoiceCommandState.listening &&
        state.state != VoiceCommandState.processing) {
      return;
    }

    // If still listening (native STT finalResult arrives before manual stop),
    // transition through processing now.
    if (state.state == VoiceCommandState.listening) {
      _cancelSilenceDetection();
      debugPrint('[VoiceCmd] recording_stopped: ${DateTime.now().toIso8601String()}');
      state = state.copyWith(
        state: VoiceCommandState.processing,
        transcript: transcript,
      );
      await _playEarcon();
    } else {
      state = state.copyWith(transcript: transcript);
    }

    debugPrint('[VoiceCmd] processing_started: ${DateTime.now().toIso8601String()}');
    debugPrint('[VoiceCmd] transcript: "$transcript"');

    try {
      final intent = _parser.parse(transcript);

      if (intent != null) {
        state = state.copyWith(
          state: VoiceCommandState.result,
          resolvedIntent: intent,
          didFail: false,
        );
      } else {
        _handleFailure();
      }
    } catch (e) {
      debugPrint('[VoiceCmd] processCommand error: $e');
      _handleFailure();
    }
  }

  void _onTranscriptError(Object error) {
    debugPrint('[VoiceCmd] transcript stream error: $error');
    _handleFailure();
  }

  void _handleFailure() {
    state = state.copyWith(
      state: VoiceCommandState.result,
      didFail: true,
      clearIntent: true,
    );
  }

  void _resetToIdle() {
    _isActive = false;
    state = const VoiceOverlayData(state: VoiceCommandState.idle);
  }

  // ─── Silence detection (Whisper / batch engines only) ───────────────────

  void _startAmplitudeSilenceDetection() {
    final recorder = AudioRecorder();
    // Amplitude stream at 200 ms intervals
    _amplitudeSub = recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      // dB threshold: below -35 dB is considered silence
      if (amp.current < -35.0) {
        // Start or keep the silence countdown
        _silenceTimer ??= Timer(
          const Duration(milliseconds: 1800),
          () {
            debugPrint('[VoiceCmd] Silence detected — auto-stopping recording.');
            stopRecording();
          },
        );
      } else {
        // Speech resumed — cancel the pending silence timer
        _silenceTimer?.cancel();
        _silenceTimer = null;
      }
    });
  }

  void _cancelSilenceDetection() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
  }

  // ─── Earcon ─────────────────────────────────────────────────────────────

  Future<void> _playEarcon() async {
    try {
      await _earconTts.setLanguage('en-US');
      await _earconTts.setSpeechRate(0.5);
      await _earconTts.speak('Processing');
    } catch (e) {
      debugPrint('[VoiceCmd] Earcon TTS error (non-fatal): $e');
    }
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  void _cleanup() {
    _cancelSilenceDetection();
    _transcriptSub?.cancel();
    _transcriptSub = null;
    _interimSub?.cancel();
    _interimSub = null;
    _isActive = false;
  }
}
