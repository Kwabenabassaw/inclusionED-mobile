import 'package:opencampus_lms/core/enums/playback_state.dart';

class AudioPlayerState {
  final PlaybackState playbackState;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final String selectedVoice;
  final String? currentLessonId;
  final String? error;

  const AudioPlayerState({
    this.playbackState = PlaybackState.idle,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playbackSpeed = 1.0,
    this.selectedVoice = 'Joanna',
    this.currentLessonId,
    this.error,
  });

  AudioPlayerState copyWith({
    PlaybackState? playbackState,
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
      playbackState: playbackState ?? this.playbackState,
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
