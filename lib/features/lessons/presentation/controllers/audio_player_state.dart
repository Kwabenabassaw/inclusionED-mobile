import 'package:flutter/foundation.dart';

class AudioPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final String selectedVoice;
  final String? currentLessonId;
  final String? error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.selectedVoice = 'Joanna',
    this.currentLessonId,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    String? selectedVoice,
    String? currentLessonId,
    bool clearLessonId = false,
    String? error,
    bool clearError = false,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      currentLessonId: clearLessonId ? null : (currentLessonId ?? this.currentLessonId),
      error: clearError ? null : (error ?? this.error),
    );
  }
}
