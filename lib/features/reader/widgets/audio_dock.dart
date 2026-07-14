import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/widgets/accessible_button.dart';
import 'package:opencampus_lms/core/widgets/accessible_text.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/reader/providers/reader_state_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';

/// Audio playback dock for the Accessible Reader screen.
///
/// All playback operations are exclusively routed through [PlaybackController]
/// to ensure the state machine remains consistent. [TtsService] is not used
/// here; the controller owns the engine internally.
class AudioDock extends ConsumerWidget {
  const AudioDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read ttsAvailable from ReaderState (set during content load).
    final ttsAvailable = ref.watch(readerStateProvider.select((s) => s.ttsAvailable));

    // All other playback state comes from the authoritative controller.
    final playbackData = ref.watch(playbackControllerProvider);
    final displayText = ref.watch(readerStateProvider.select((s) => s.displayText));
    final accessibilitySettings = ref.watch(accessibilityProvider);

    if (!ttsAvailable) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        color: Theme.of(context).colorScheme.surface,
        child: const AccessibleText('Audio playback is unavailable on this device.'),
      );
    }

    final isSpeaking = playbackData.state == PlaybackState.speaking;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            // Play / Pause
            AccessibleButton(
              onPressed: () {
                if (isSpeaking) {
                  ref.read(playbackControllerProvider.notifier).pause();
                } else {
                  // Pass displayText — PlaybackController normalises it for
                  // the engine internally, keeping the state machine as the
                  // sole authority over what is actually spoken.
                  ref.read(playbackControllerProvider.notifier).playOrResume(displayText);
                }
              },
              label: isSpeaking ? 'Pause reading aloud' : 'Play reading aloud',
              child: Icon(isSpeaking ? Icons.pause : Icons.play_arrow),
            ),
            SizedBox(width: 8),

            // Stop
            AccessibleButton(
              onPressed: () {
                ref.read(playbackControllerProvider.notifier).stopForNavigation();
              },
              label: 'Stop reading aloud',
              child: Icon(Icons.stop),
            ),
            SizedBox(width: 16),

            // Speed slider
            const AccessibleText('Speed'),
            Expanded(
              child: Semantics(
                slider: true,
                label: 'Reading Speed',
                value: '${accessibilitySettings.readingSpeed.toStringAsFixed(1)}x',
                child: Slider(
                  value: accessibilitySettings.readingSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (val) {
                    // Persist the new speed in accessibility settings.
                    ref.read(accessibilityProvider.notifier).setReadingSpeed(val);
                    // Apply to the active engine immediately so the user hears
                    // the change without having to stop and restart playback.
                    if (isSpeaking) {
                      ref.read(playbackControllerProvider.notifier).changeSettingsAndResume();
                    }
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
