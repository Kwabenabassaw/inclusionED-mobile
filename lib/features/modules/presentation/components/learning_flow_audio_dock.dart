import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';

class LearningFlowAudioDock extends ConsumerStatefulWidget {
  const LearningFlowAudioDock({super.key});

  @override
  ConsumerState<LearningFlowAudioDock> createState() => _LearningFlowAudioDockState();
}

class _LearningFlowAudioDockState extends ConsumerState<LearningFlowAudioDock> {
  bool _isPanelExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textToRead = ref.watch(currentReadableTextProvider);
    final playback = ref.watch(playbackControllerProvider);
    final accessSettings = ref.watch(accessibilityProvider);
    final theme = Theme.of(context);

    // If there's no text to read, don't show the dock.
    if (textToRead.isEmpty) return const SizedBox.shrink();

    final isPolly = accessSettings.ttsEngine == 'polly';
    final currentSpeed = isPolly ? accessSettings.pollySpeed : accessSettings.nativeSpeed;
    final currentPitch = isPolly ? accessSettings.pollyPitch : accessSettings.nativePitch;
    final currentVolume = isPolly ? accessSettings.pollyVolume : accessSettings.nativeVolume;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isPanelExpanded)
            // Compact Collapsed Single Row Layout
            Row(
              children: [
                // Mini Play/Pause button
                Semantics(
                  button: true,
                  label: playback.state == PlaybackState.speaking ? 'Pause reading' : 'Play reading',
                  child: IconButton(
                    icon: Icon(
                      playback.state == PlaybackState.speaking 
                          ? Icons.pause_circle_filled 
                          : Icons.play_circle_filled,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => ref.read(playbackControllerProvider.notifier).togglePlayPause(textToRead),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        playback.state == PlaybackState.speaking ? 'Now Reading' : 'Audio Reader',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${currentSpeed.toStringAsFixed(1)}x speed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Skip backward 30s
                IconButton(
                  icon: const Icon(Icons.replay_30, size: 22),
                  color: theme.colorScheme.primary,
                  tooltip: 'Rewind 30 seconds',
                  onPressed: () => ref.read(playbackControllerProvider.notifier).skip(-450),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                // Skip forward 30s
                IconButton(
                  icon: const Icon(Icons.forward_30, size: 22),
                  color: theme.colorScheme.primary,
                  tooltip: 'Forward 30 seconds',
                  onPressed: () => ref.read(playbackControllerProvider.notifier).skip(450),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                // Chevron to expand settings
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up, size: 24),
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: 'Expand Settings',
                  onPressed: () {
                    setState(() {
                      _isPanelExpanded = true;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            )
          else ...[
            // Expanded Layout
            Row(
              children: [
                Icon(Icons.volume_up, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  playback.state == PlaybackState.speaking ? 'Now Reading' : 'Audio Reader',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Chevron to collapse settings
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down, size: 24),
                  color: theme.colorScheme.onSurfaceVariant,
                  tooltip: 'Collapse Settings',
                  onPressed: () {
                    setState(() {
                      _isPanelExpanded = false;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Media playback buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_30, size: 28),
                  color: theme.colorScheme.primary,
                  tooltip: 'Rewind 30 seconds',
                  onPressed: () => ref.read(playbackControllerProvider.notifier).skip(-450),
                ),
                const SizedBox(width: 24),
                Semantics(
                  button: true,
                  label: playback.state == PlaybackState.speaking ? 'Pause reading' : 'Play reading',
                  child: GestureDetector(
                    onTap: () => ref.read(playbackControllerProvider.notifier).togglePlayPause(textToRead),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        playback.state == PlaybackState.speaking ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.forward_30, size: 28),
                  color: theme.colorScheme.primary,
                  tooltip: 'Forward 30 seconds',
                  onPressed: () => ref.read(playbackControllerProvider.notifier).skip(450),
                ),
              ],
            ),

            // Settings sliders (expanded panel)
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Engine Selector
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text("Engine", style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  DropdownButton<String>(
                    value: accessSettings.ttsEngine,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                    items: const [
                      DropdownMenuItem(value: 'polly', child: Text('AWS Polly (Cloud)')),
                      DropdownMenuItem(value: 'native', child: Text('System (Offline)')),
                    ],
                    onChanged: (String? newEngine) async {
                      if (newEngine != null && newEngine != accessSettings.ttsEngine) {
                        ref.read(accessibilityProvider.notifier).setTtsEngine(newEngine);
                        if (playback.state == PlaybackState.speaking || playback.state == PlaybackState.pausedByUser) {
                          await ref.read(playbackControllerProvider.notifier).stopForNavigation();
                          await Future.delayed(const Duration(milliseconds: 100));
                          await ref.read(playbackControllerProvider.notifier).playOrResume(textToRead);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            // Voice Selector (Only for Polly)
            if (accessSettings.ttsEngine == 'polly') Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text("Voice", style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  DropdownButton<String>(
                    value: ref.watch(playbackControllerProvider).voice,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    underline: const SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                    items: const [
                      DropdownMenuItem(value: 'Joanna', child: Text('Joanna (Female)')),
                      DropdownMenuItem(value: 'Salli', child: Text('Salli (Female)')),
                      DropdownMenuItem(value: 'Matthew', child: Text('Matthew (Male)')),
                      DropdownMenuItem(value: 'Justin', child: Text('Justin (Child)')),
                      DropdownMenuItem(value: 'Kendra', child: Text('Kendra (Female)')),
                      DropdownMenuItem(value: 'Joey', child: Text('Joey (Male)')),
                      DropdownMenuItem(value: 'Ivy', child: Text('Ivy (Child)')),
                      DropdownMenuItem(value: 'Kevin', child: Text('Kevin (Child)')),
                    ],
                    onChanged: (String? newVoice) {
                      if (newVoice != null) {
                        ref.read(playbackControllerProvider.notifier).setVoice(newVoice);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Reading Speed Slider
            _buildSettingSlider(
              context: context,
              title: "Reading Speed",
              value: currentSpeed,
              min: 0.5,
              max: 3.0,
              icon: Icons.speed,
              onChanged: (val) {
                if (isPolly) {
                  ref.read(accessibilityProvider.notifier).setPollySpeed(val);
                } else {
                  ref.read(accessibilityProvider.notifier).setNativeSpeed(val);
                }
              },
              onChangeEnd: (val) async {
                await ref.read(playbackControllerProvider.notifier).changeSettingsAndResume();
              },
              formatValue: (val) => "${val.toStringAsFixed(1)}x",
            ),

            // Reading Pitch Slider
            _buildSettingSlider(
              context: context,
              title: "Reading Pitch",
              value: currentPitch,
              min: 0.5,
              max: 2.0,
              icon: Icons.music_note,
              onChanged: (val) {
                if (isPolly) {
                  ref.read(accessibilityProvider.notifier).setPollyPitch(val);
                } else {
                  ref.read(accessibilityProvider.notifier).setNativePitch(val);
                }
              },
              onChangeEnd: (val) async {
                await ref.read(playbackControllerProvider.notifier).changeSettingsAndResume();
              },
              formatValue: (val) => val.toStringAsFixed(1),
            ),

            // Reading Volume Slider
            _buildSettingSlider(
              context: context,
              title: "Reading Volume",
              value: currentVolume,
              min: 0.0,
              max: 1.0,
              icon: Icons.volume_up,
              onChanged: (val) {
                if (isPolly) {
                  ref.read(accessibilityProvider.notifier).setPollyVolume(val);
                } else {
                  ref.read(accessibilityProvider.notifier).setNativeVolume(val);
                }
              },
              onChangeEnd: (val) async {
                await ref.read(playbackControllerProvider.notifier).changeSettingsAndResume();
              },
              formatValue: (val) => "${(val * 100).toInt()}%",
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingSlider({
    required BuildContext context,
    required String title,
    required double value,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
    required String Function(double) formatValue,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(title, style: theme.textTheme.bodyMedium),
                ],
              ),
              Text(
                formatValue(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}
