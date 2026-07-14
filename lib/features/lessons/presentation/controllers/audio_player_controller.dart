import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../data/tts_repository.dart';
import '../../data/audio_cache_service.dart';
import '../../data/playback_progress_service.dart';
import 'audio_player_state.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';

final audioPlayerControllerProvider = NotifierProvider<AudioPlayerController, AudioPlayerState>(() {
  return AudioPlayerController();
});

class AudioPlayerController extends Notifier<AudioPlayerState> {
  TtsRepository get _ttsRepository => ref.read(ttsRepositoryProvider);
  AudioCacheService get _cacheService => ref.read(audioCacheServiceProvider);
  PlaybackProgressService get _progressService => ref.read(playbackProgressServiceProvider);

  final AudioPlayer _player = AudioPlayer();

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _stateSub;
  Timer? _debounceTimer;

  @override
  AudioPlayerState build() {
    _init();
    
    // We handle disposal manually using Riverpod's ref.onDispose
    ref.onDispose(() {
      _positionSub?.cancel();
      _durationSub?.cancel();
      _stateSub?.cancel();
      _debounceTimer?.cancel();
      _player.dispose();
    });
    
    return const AudioPlayerState();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    _positionSub = _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
      _debounceSaveProgress();
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    _stateSub = _player.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.completed) {
        state = state.copyWith(playbackState: PlaybackState.idle);
        _saveProgress(completed: true);
      } else {
        if (state.playbackState == PlaybackState.stoppedForNavigation && !isPlaying) {
          // Keep stoppedForNavigation state if it was explicitly set
        } else {
          state = state.copyWith(playbackState: isPlaying ? PlaybackState.speaking : PlaybackState.pausedByUser);
        }
      }
    });
  }

  void _debounceSaveProgress() {
    if (_debounceTimer?.isActive ?? false) return;
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _saveProgress();
      _debounceTimer = null;
    });
  }

  Future<void> _saveProgress({bool? completed}) async {
    if (state.currentLessonId == null || state.duration.inSeconds == 0) return;

    final progressRatio = state.position.inMilliseconds / state.duration.inMilliseconds;
    final isCompleted = completed ?? (progressRatio >= 0.90);

    await _progressService.saveProgress(
      lessonId: state.currentLessonId!,
      lastPositionSeconds: state.position.inMilliseconds / 1000.0,
      durationSeconds: state.duration.inMilliseconds / 1000.0,
      completed: isCompleted,
      playbackSpeed: state.playbackSpeed,
      voice: state.selectedVoice,
    );
  }

  Future<void> playLesson({required String lessonId, required String text}) async {
    try {
      if (state.currentLessonId == lessonId && state.playbackState == PlaybackState.speaking) return;

      if (state.currentLessonId == lessonId) {
        if (_player.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
        }
        await _player.play();
        return;
      }

      state = state.copyWith(isLoading: true, clearError: true, currentLessonId: lessonId);

      // Check offline progress to resume
      final savedProgress = await _progressService.getProgress(lessonId);
      double resumePositionSeconds = 0.0;
      if (savedProgress != null && !(savedProgress['completed'] as bool? ?? false)) {
         resumePositionSeconds = (savedProgress['lastPosition'] as num? ?? 0.0).toDouble();
      }

      // Strip basic markdown characters so Polly doesn't read them out loud
      final cleanText = text.replaceAll(RegExp(r'[#\*_\[\]<>\!]'), '').trim();
      final textHash = cleanText.hashCode;
      final uniqueLessonId = '${lessonId}_$textHash';

      final cacheKey = '${uniqueLessonId}_${state.selectedVoice}';
      
      String? localPath = await _cacheService.getCachedFilePath(cacheKey);

      if (localPath == null) {
        // Attempt to get signed URL and download if not cached
        final url = await _ttsRepository.getLessonAudioUrl(
          lessonId: uniqueLessonId,
          text: cleanText,
          voice: state.selectedVoice,
        );
        localPath = await _cacheService.getCachedAudioPath(url as String, cacheKey);
      }

      await _player.setFilePath(localPath);
      await _player.setSpeed(state.playbackSpeed);

      if (resumePositionSeconds > 0) {
        await _player.seek(Duration(milliseconds: (resumePositionSeconds * 1000).toInt()));
      }

      state = state.copyWith(isLoading: false);
      await _player.play();

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> pause() async {
    state = state.copyWith(playbackState: PlaybackState.pausedByUser);
    await _player.pause();
    await _saveProgress();
  }

  Future<void> stop() async {
    state = state.copyWith(playbackState: PlaybackState.stoppedForNavigation);
    await _player.stop();
    await _saveProgress();
    state = state.copyWith(position: Duration.zero);
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  Future<void> setVoice(String voice, String currentText) async {
    state = state.copyWith(selectedVoice: voice);
    if (state.currentLessonId != null) {
      final lessonId = state.currentLessonId!;
      state = state.copyWith(clearLessonId: true); // Force reload
      await playLesson(lessonId: lessonId, text: currentText);
    }
  }
}
