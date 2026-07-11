import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/audio_player_controller.dart';
import 'audio_settings_sheet.dart';

class AudioToolbar extends ConsumerWidget {
  final String lessonId;
  final String lessonText;

  const AudioToolbar({
    super.key,
    required this.lessonId,
    required this.lessonText,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds".replaceFirst("00:", "");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioPlayerControllerProvider);
    final controller = ref.read(audioPlayerControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar
            Semantics(
              slider: true,
              value: '${state.position.inSeconds}',
              child: Slider(
                value: state.position.inSeconds.toDouble().clamp(0.0, state.duration.inSeconds.toDouble()),
                max: state.duration.inSeconds.toDouble() > 0 ? state.duration.inSeconds.toDouble() : 1.0,
                onChanged: (val) {
                  controller.seek(Duration(seconds: val.toInt()));
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(state.position),
                  semanticsLabel: "Current position ${_formatDuration(state.position)}",
                ),
                Text(
                  "-${_formatDuration(state.duration - state.position)}",
                  semanticsLabel: "Remaining time ${_formatDuration(state.duration - state.position)}",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Audio Settings',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => AudioSettingsSheet(
                        currentText: lessonText,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                if (state.isLoading)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    iconSize: 48,
                    icon: Icon(state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                    tooltip: state.isPlaying ? 'Pause' : 'Play',
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      if (state.isPlaying) {
                        controller.pause();
                      } else {
                        controller.playLesson(lessonId: lessonId, text: lessonText);
                      }
                    },
                  ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                  onPressed: () {
                    controller.stop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
