import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/providers/voice_overlay_controller.dart';
import 'package:opencampus_lms/core/services/intent/command_interpreter.dart';
import 'package:opencampus_lms/core/services/voice/native_speech_engine.dart';
import 'package:opencampus_lms/core/services/voice/speech_engine.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/assistant/presentation/voice_action_handler.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';

final fuzzyCommandInterpreterProvider = Provider<CommandInterpreter>((ref) {
  return CommandInterpreter();
});

final speechEngineProvider = Provider<SpeechEngine>((ref) {
  return NativeSpeechEngine();
});

// Assuming a UnifiedTtsController provider exists, or we create a simple one
final fallbackTtsProvider = Provider<UnifiedTtsController>((ref) {
  return UnifiedTtsController()..initialize();
});

final voiceActionHandlerProvider = Provider<VoiceActionHandler>((ref) {
  return VoiceActionHandler(
    playbackController: ref.read(playbackControllerProvider.notifier),
    fallbackTts: ref.read(fallbackTtsProvider),
    accessibilityController: ref.read(accessibilityProvider.notifier),
    ref: ref,
  );
});

/// Provider for the Google Assistant-style voice overlay state machine.
/// Exposed globally so both the FAB and the overlay widget share the same
/// controller instance.
final voiceOverlayControllerProvider =
    NotifierProvider<VoiceOverlayController, VoiceOverlayData>(
  VoiceOverlayController.new,
);
