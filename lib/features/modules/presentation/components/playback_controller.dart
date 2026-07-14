import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:opencampus_lms/features/lessons/data/tts_repository.dart';
import 'package:opencampus_lms/features/lessons/data/audio_cache_service.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:opencampus_lms/core/enums/playback_state.dart';

class PlaybackData {
  final PlaybackState state;
  final String currentTextToSpeak;
  final int highlightStart;
  final int highlightEnd;
  final int playOffset;
  final String voice;
  final String? errorMessage;

  const PlaybackData({
    this.state = PlaybackState.idle,
    this.currentTextToSpeak = '',
    this.highlightStart = 0,
    this.highlightEnd = 0,
    this.playOffset = 0,
    this.voice = 'Joanna',
    this.errorMessage,
  });

  PlaybackData copyWith({
    PlaybackState? state,
    String? currentTextToSpeak,
    int? highlightStart,
    int? highlightEnd,
    int? playOffset,
    String? voice,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlaybackData(
      state: state ?? this.state,
      currentTextToSpeak: currentTextToSpeak ?? this.currentTextToSpeak,
      highlightStart: highlightStart ?? this.highlightStart,
      highlightEnd: highlightEnd ?? this.highlightEnd,
      playOffset: playOffset ?? this.playOffset,
      voice: voice ?? this.voice,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final playbackControllerProvider = NotifierProvider<PlaybackController, PlaybackData>(() {
  return PlaybackController();
});

class PlaybackController extends Notifier<PlaybackData> {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  // Raw Polly Speech Marks — indexed against the SSML/speechText
  final List<Map<String, dynamic>> _speechMarks = [];
  // Alignment map — translates speech token index → displayText char range
  List<Map<String, dynamic>> _alignmentMap = [];
  StreamSubscription? _positionSubscription;

  TtsRepository get _ttsRepo => ref.read(ttsRepositoryProvider);
  AudioCacheService get _cache => ref.read(audioCacheServiceProvider);

  @override
  PlaybackData build() {
    _initTts();
    ref.onDispose(() {
      _positionSubscription?.cancel();
      _player.dispose();
    });
    return const PlaybackData();
  }

  void _initTts() {
    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        state = const PlaybackData();
      }
    });

    _positionSubscription = _player.positionStream.listen((position) {
      if (_speechMarks.isEmpty || state.state != PlaybackState.speaking) return;

      final currentTime = position.inMilliseconds;
      // Find the speech mark whose timestamp has passed
      Map<String, dynamic>? currentMark;
      int currentSpeechIdx = -1;
      
      for (int i = 0; i < _speechMarks.length; i++) {
        if (_speechMarks[i]['time'] <= currentTime) {
          currentMark = _speechMarks[i];
          currentSpeechIdx = i;
        } else {
          break;
        }
      }

      if (currentMark != null && currentSpeechIdx >= 0) {
        int displayStart;
        int displayEnd;

        if (_alignmentMap.isNotEmpty && currentSpeechIdx < _alignmentMap.length) {
          // Use alignment map to resolve the CORRECT displayText char range.
          // This handles multi-word expansions (e.g. "e.g." → "for example")
          // where Polly fires 2 speech tokens but we highlight 1 display word.
          final entry = _alignmentMap[currentSpeechIdx];
          displayStart = state.playOffset + (entry['displayStart'] as int);
          displayEnd = state.playOffset + (entry['displayEnd'] as int);
        } else {
          // Fallback to raw speech mark offsets if alignment map is missing
          displayStart = state.playOffset + (currentMark['start'] as int);
          displayEnd = state.playOffset + (currentMark['end'] as int);
        }

        if (state.highlightStart != displayStart || state.highlightEnd != displayEnd) {
          state = state.copyWith(
            highlightStart: displayStart,
            highlightEnd: displayEnd,
          );
        }
      }
    });

    _flutterTts.setCompletionHandler(() {
      state = const PlaybackData();
    });

    _flutterTts.setProgressHandler((String text, int start, int end, String word) {
      if (state.state != PlaybackState.speaking) return;
      
      final actualStart = state.playOffset + start;
      final actualEnd = state.playOffset + end;

      if (state.highlightStart != actualStart || state.highlightEnd != actualEnd) {
        state = state.copyWith(
          highlightStart: actualStart,
          highlightEnd: actualEnd,
        );
      }
    });
  }

  String _stripMarkdown(String markdown) {
    String text = markdown;
    text = text.replaceAll(RegExp(r'[#*>`]'), ''); // Remove #, *, >, `
    text = text.replaceAll(RegExp(r'\n+'), ' '); // Flatten newlines
    return text.replaceAll(RegExp(r' +'), ' ').trim();
  }

  Future<void> _applyEngineSettings() async {
    final settings = ref.read(accessibilityProvider);
    final ttsEngine = settings.ttsEngine;
    if (ttsEngine == 'native') {
      // Map UI speed (0.5 to 3.0) to flutter_tts speech rate
      // 1.0 UI speed maps to 0.5 normal rate in flutter_tts
      await _flutterTts.setSpeechRate(settings.nativeSpeed * 0.5);
      await _flutterTts.setPitch(settings.nativePitch);
      await _flutterTts.setVolume(settings.nativeVolume);
      
      if (settings.nativeVoice != 'default' && settings.nativeVoice.isNotEmpty) {
        try {
          await _flutterTts.setVoice({"name": settings.nativeVoice, "locale": "en-US"});
        } catch (_) {}
      }
    } else {
      await _player.setSpeed(settings.pollySpeed);
      await _player.setPitch(settings.pollyPitch);
      await _player.setVolume(settings.pollyVolume);
    }
  }

  Future<void> togglePlayPause(String fullText) async {
    if (state.state == PlaybackState.speaking) {
      await pause();
    } else {
      await playOrResume(fullText);
    }
  }

  Future<void> playOrResume(String fullText) async {
    final settings = ref.read(accessibilityProvider);

    // If the user's OS screen reader (TalkBack/VoiceOver) is active, suppress
    // all app-native narration to prevent double-narration.
    if (settings.screenReaderEnabled) return;

    final strippedText = _stripMarkdown(fullText);
    final voice = settings.ttsEngine == 'native' ? settings.nativeVoice : settings.pollyVoice;

    if (state.currentTextToSpeak.isEmpty || state.currentTextToSpeak != strippedText || state.voice != voice) {
      state = state.copyWith(
        currentTextToSpeak: strippedText,
        playOffset: 0,
        highlightStart: 0,
        highlightEnd: 0,
        voice: voice,
      );
    }

    state = state.copyWith(
      state: PlaybackState.speaking,
      clearError: true,
    );
    await _applyEngineSettings();
    
    final ttsEngine = settings.ttsEngine;
    
    try {
      final textToSpeak = state.currentTextToSpeak.substring(state.playOffset);
      
      if (ttsEngine == 'native') {
        await _flutterTts.setLanguage("en-US");
        await _flutterTts.speak(textToSpeak);
        return;
      }
      
      final cacheKey = 'screen_reader_${textToSpeak.hashCode}_$voice';
      String speechMarksJson;
      String alignmentJson;

      if (kIsWeb) {
        // ── Web path ──────────────────────────────────────────────────────────
        // flutter_cache_manager writes to dart:io File, which doesn't exist on
        // web. just_audio's web backend also rejects setFilePath(). Instead:
        //   • stream audio directly from the signed Supabase URL via setUrl()
        //   • fetch JSON payloads over HTTP with Dio (no file I/O needed)
        final urls = await _ttsRepo.getLessonAudioUrl(
          lessonId: cacheKey,
          text: textToSpeak.length > 3000 ? textToSpeak.substring(0, 3000) : textToSpeak,
          voice: voice,
        );

        // Fetch speech marks and alignment via HTTP
        final dio = Dio();
        final marksRes = await dio.get<String>(
          urls.marksUrl,
          options: Options(responseType: ResponseType.plain),
        );
        final alignRes = await dio.get<String>(
          urls.alignmentUrl,
          options: Options(responseType: ResponseType.plain),
        );

        speechMarksJson = marksRes.data ?? '';
        alignmentJson = alignRes.data ?? '';

        // Stream audio directly — no local file involved
        await _player.setUrl(urls.audioUrl);
      } else {
        // ── Native (iOS / Android) path ───────────────────────────────────────
        // Download to local cache first; setFilePath() is faster for large files
        // and avoids re-downloading the same audio on repeated plays.
        String? localPath = await _cache.getCachedFilePath(cacheKey);
        String? cachedMarks = await _cache.getCachedSpeechMarksString(cacheKey);
        String? cachedAlign = await _cache.getCachedAlignmentString(cacheKey);

        if (localPath == null || cachedMarks == null || cachedAlign == null) {
          final urls = await _ttsRepo.getLessonAudioUrl(
            lessonId: cacheKey,
            text: textToSpeak.length > 3000 ? textToSpeak.substring(0, 3000) : textToSpeak,
            voice: voice,
          );
          localPath = await _cache.getCachedAudioPath(urls.audioUrl, cacheKey);
          cachedMarks = await _cache.getCachedSpeechMarks(urls.marksUrl, cacheKey);
          cachedAlign = await _cache.getCachedAlignment(urls.alignmentUrl, cacheKey);
        }

        speechMarksJson = cachedMarks;
        alignmentJson = cachedAlign;

        await _player.setFilePath(localPath);
      }

      // ── Shared: parse speech marks + alignment, then play ─────────────────
      _speechMarks.clear();
      for (var line in speechMarksJson.split('\n')) {
        if (line.trim().isNotEmpty) {
          try {
            _speechMarks.add(jsonDecode(line));
          } catch (_) {}
        }
      }

      _alignmentMap.clear();
      try {
        final decoded = jsonDecode(alignmentJson) as List<dynamic>;
        _alignmentMap = decoded.map((e) => e as Map<String, dynamic>).toList();
      } catch (_) {
        debugPrint('PlaybackController: Failed to parse alignment map; falling back to raw offsets.');
      }

      await _player.play();
    } catch (e) {
      debugPrint('Error playing TTS: $e');
      state = const PlaybackData(
        errorMessage: 'Failed to play audio. Please check your connection.',
      );
    }
  }

  Future<void> pause() async {
    if (state.state != PlaybackState.speaking) return;

    state = state.copyWith(
      state: PlaybackState.pausedByUser,
      playOffset: state.highlightStart,
      highlightStart: 0,
      highlightEnd: 0,
    );

    final ttsEngine = ref.read(accessibilityProvider).ttsEngine;
    if (ttsEngine == 'native') {
      await _flutterTts.stop();
    } else {
      await _player.pause();
    }
  }

  Future<void> skip(int characters) async {
    if (state.currentTextToSpeak.isEmpty) return;

    final wasSpeaking = state.state == PlaybackState.speaking;
    
    state = state.copyWith(
      state: PlaybackState.restartingForSettings,
    );
    
    final ttsEngine = ref.read(accessibilityProvider).ttsEngine;
    if (ttsEngine == 'native') {
      await _flutterTts.stop();
    } else {
      await _player.stop();
    }

    int newOffset = state.highlightStart + characters;
    if (newOffset < 0) newOffset = 0;
    if (newOffset >= state.currentTextToSpeak.length) {
      newOffset = state.currentTextToSpeak.length - 1;
    }
    if (newOffset < 0) newOffset = 0;

    state = state.copyWith(
      playOffset: newOffset,
      highlightStart: newOffset,
      highlightEnd: newOffset,
    );

    if (wasSpeaking) {
      await Future.delayed(const Duration(milliseconds: 150));
      await playOrResume(state.currentTextToSpeak);
    } else {
      state = state.copyWith(state: PlaybackState.pausedByUser);
    }
  }

  Future<void> changeSettingsAndResume() async {
    final ttsEngine = ref.read(accessibilityProvider).ttsEngine;
    
    await _applyEngineSettings();
  }

  Future<void> setVoice(String newVoice) async {
    final settings = ref.read(accessibilityProvider);
    final ttsEngine = settings.ttsEngine;

    if (ttsEngine == 'native') {
      ref.read(accessibilityProvider.notifier).setNativeVoice(newVoice);
    } else {
      ref.read(accessibilityProvider.notifier).setPollyVoice(newVoice);
    }
    
    state = state.copyWith(voice: newVoice);
    
    if (state.state == PlaybackState.speaking || state.state == PlaybackState.pausedByUser) {
      state = state.copyWith(
        state: PlaybackState.restartingForSettings,
        playOffset: state.highlightStart,
      );
      
      if (ttsEngine == 'native') {
        await _flutterTts.stop();
      } else {
        await _player.stop();
      }
      
      await playOrResume(state.currentTextToSpeak);
    }
  }

  Future<void> stopForNavigation() async {
    if (state.state == PlaybackState.stoppedForNavigation || state.state == PlaybackState.idle) return;

    state = state.copyWith(
      state: PlaybackState.stoppedForNavigation,
      highlightStart: 0,
      highlightEnd: 0,
    );
    
    final ttsEngine = ref.read(accessibilityProvider).ttsEngine;
    if (ttsEngine == 'native') {
      await _flutterTts.stop();
    } else {
      await _player.stop();
    }
  }
}
