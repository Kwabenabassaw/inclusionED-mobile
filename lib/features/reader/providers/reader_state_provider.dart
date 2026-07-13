import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderState {
  final int highlightStart;
  final int highlightEnd;
  final bool isPlaying;
  final bool ttsAvailable;
  final String text;

  const ReaderState({
    this.highlightStart = 0,
    this.highlightEnd = 0,
    this.isPlaying = false,
    this.ttsAvailable = true,
    this.text = '',
  });

  ReaderState copyWith({
    int? highlightStart,
    int? highlightEnd,
    bool? isPlaying,
    bool? ttsAvailable,
    String? text,
  }) {
    return ReaderState(
      highlightStart: highlightStart ?? this.highlightStart,
      highlightEnd: highlightEnd ?? this.highlightEnd,
      isPlaying: isPlaying ?? this.isPlaying,
      ttsAvailable: ttsAvailable ?? this.ttsAvailable,
      text: text ?? this.text,
    );
  }
}

class ReaderStateNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  void updateHighlight(int start, int end) {
    state = state.copyWith(highlightStart: start, highlightEnd: end);
  }

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void setTtsAvailable(bool available) {
    state = state.copyWith(ttsAvailable: available);
  }
  
  void setText(String text) {
    state = state.copyWith(text: text);
  }
}

final readerStateProvider = NotifierProvider<ReaderStateNotifier, ReaderState>(() {
  return ReaderStateNotifier();
});
