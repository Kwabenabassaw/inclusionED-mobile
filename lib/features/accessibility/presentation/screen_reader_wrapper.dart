import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:inclusive_ed_student/features/accessibility/data/accessibility_provider.dart';
import 'package:inclusive_ed_student/features/lessons/data/tts_repository.dart';

class SpeakOnTap extends ConsumerStatefulWidget {
  final Widget child;
  final String textToSpeak;
  final VoidCallback? onActivate; // Optional action to perform on double-tap

  const SpeakOnTap({
    super.key,
    required this.child,
    required this.textToSpeak,
    this.onActivate,
  });

  @override
  ConsumerState<SpeakOnTap> createState() => _SpeakOnTapState();
}

class _SpeakOnTapState extends ConsumerState<SpeakOnTap> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    final settings = ref.read(accessibilityProvider);
    final ttsRepo = ref.read(ttsRepositoryProvider);
    
    try {
      await _player.setSpeed(settings.readingSpeed);
      
      final String voice = settings.preferredVoice != 'default' ? settings.preferredVoice : 'Joanna';

      final urls = await ttsRepo.getLessonAudioUrl(
        lessonId: 'speak_on_tap_${widget.textToSpeak.hashCode}',
        text: widget.textToSpeak.length > 500 ? widget.textToSpeak.substring(0, 500) : widget.textToSpeak,
        voice: voice,
      );

      await _player.setUrl(urls.audioUrl);
      await _player.play();
    } catch (e) {
      debugPrint('SpeakOnTap error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = ref.watch(accessibilityProvider.select((s) => s.screenReaderEnabled));

    if (!isEnabled) {
      // If screen reader is off, just wrap with Semantics for native OS screen readers
      return Semantics(
        label: widget.textToSpeak,
        child: widget.child,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _speak();
        // Show visual feedback
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.textToSpeak),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      onDoubleTap: widget.onActivate,
      child: Semantics(
        label: widget.textToSpeak,
        hint: widget.onActivate != null ? 'Double tap to activate' : null,
        child: IgnorePointer(
          ignoring: true, // Prevent child buttons from triggering on single tap
          child: widget.child,
        ),
      ),
    );
  }
}
