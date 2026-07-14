import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';

class ReaderState {
  final int highlightStart;
  final int highlightEnd;
  final PlaybackState playbackState;
  final bool ttsAvailable;
  final String displayText;
  final String speechText;

  const ReaderState({
    this.highlightStart = 0,
    this.highlightEnd = 0,
    this.playbackState = PlaybackState.idle,
    this.ttsAvailable = true,
    this.displayText = '',
    this.speechText = '',
  });

  ReaderState copyWith({
    int? highlightStart,
    int? highlightEnd,
    PlaybackState? playbackState,
    bool? ttsAvailable,
    String? displayText,
    String? speechText,
  }) {
    return ReaderState(
      highlightStart: highlightStart ?? this.highlightStart,
      highlightEnd: highlightEnd ?? this.highlightEnd,
      playbackState: playbackState ?? this.playbackState,
      ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      displayText: displayText ?? this.displayText,
      speechText: speechText ?? this.speechText,
    );
  }
}

class ReaderStateNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  void updateHighlight(int start, int end) {
    state = state.copyWith(highlightStart: start, highlightEnd: end);
  }

  void setPlaybackState(PlaybackState playbackState) {
    state = state.copyWith(playbackState: playbackState);
  }

  void setTtsAvailable(bool available) {
    state = state.copyWith(ttsAvailable: available);
  }
  
  void setText({required String displayText, required String speechText}) {
    state = state.copyWith(displayText: displayText, speechText: speechText);
  }
}

final readerStateProvider = NotifierProvider<ReaderStateNotifier, ReaderState>(() {
  return ReaderStateNotifier();
});
