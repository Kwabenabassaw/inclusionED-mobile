import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/widgets/accessible_button.dart';
import 'package:opencampus_lms/core/widgets/accessible_text.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/reader/providers/reader_state_provider.dart';
import 'package:opencampus_lms/core/services/tts_service.dart';

class AudioDock extends ConsumerStatefulWidget {
  final TtsService ttsService;

  const AudioDock({super.key, required this.ttsService});

  @override
  ConsumerState<AudioDock> createState() => _AudioDockState();
}

class _AudioDockState extends ConsumerState<AudioDock> {
  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerStateProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);

    if (!readerState.ttsAvailable) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.surface,
        child: const AccessibleText("Audio playback is unavailable on this device."),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            AccessibleButton(
              onPressed: () {
                if (readerState.isPlaying) {
                  widget.ttsService.stop();
                  ref.read(readerStateProvider.notifier).setPlaying(false);
                } else {
                  widget.ttsService.speak(readerState.text);
                  ref.read(readerStateProvider.notifier).setPlaying(true);
                }
              },
              label: readerState.isPlaying ? 'Pause reading aloud' : 'Play reading aloud',
              child: Icon(readerState.isPlaying ? Icons.pause : Icons.play_arrow),
            ),
            const SizedBox(width: 8),
            AccessibleButton(
              onPressed: () {
                widget.ttsService.stop();
                ref.read(readerStateProvider.notifier).setPlaying(false);
                ref.read(readerStateProvider.notifier).updateHighlight(0, 0);
              },
              label: 'Stop reading aloud',
              child: const Icon(Icons.stop),
            ),
            const SizedBox(width: 16),
            const AccessibleText("Speed"),
            Expanded(
              child: Semantics(
                slider: true,
                label: 'Reading Speed',
                value: '${accessibilitySettings.readingSpeed.toStringAsFixed(1)}x',
                child: Slider(
                  value: accessibilitySettings.readingSpeed,
                  min: 0.5,
                  max: 1.5,
                  divisions: 10,
                  onChanged: (val) {
                    ref.read(accessibilityProvider.notifier).setReadingSpeed(val);
                    widget.ttsService.setSpeechRate(val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
