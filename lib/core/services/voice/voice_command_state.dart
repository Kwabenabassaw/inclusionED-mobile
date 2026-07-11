/// Explicit state machine states for the Google Assistant-style voice command
/// overlay flow.
///
/// Transitions:
///   idle        → listening   : FAB tap (guarded against concurrent sessions)
///   listening   → processing  : 1.8 s silence OR manual tap-to-stop
///   processing  → result      : [LlmIntentParser.processCommand] resolves
///   result      → idle        : auto-dismiss (success) or "Try Again" (failure)
///   any         → idle        : cancel tap / barrier dismiss
enum VoiceCommandState {
  /// Default. Overlay is not shown. FAB is interactive.
  idle,

  /// Overlay visible, mic pulsing, audio capture active.
  listening,

  /// Overlay visible, spinner shown, earcon played, transcription running.
  processing,

  /// Intent resolved (success or failure). Overlay showing result briefly.
  result,
}
