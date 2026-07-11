import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:inclusive_ed_student/features/courses/data/course_repository.dart';

import 'package:visibility_detector/visibility_detector.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/modules/data/module_repository.dart';
import 'package:inclusive_ed_student/features/accessibility/data/accessibility_provider.dart';
import 'playback_controller.dart';


class LearningFlowReader extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;

  const LearningFlowReader({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<LearningFlowReader> createState() => _LearningFlowReaderState();
}

class _LearningFlowReaderState extends ConsumerState<LearningFlowReader> {
  bool _isPanelExpanded = false;
  
  double _scrollDepth = 0.0;
  int _timeSpentSeconds = 0;
  Timer? _trackingTimer;

  @override
  void initState() {
    super.initState();

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeSpentSeconds++;
      if (_timeSpentSeconds % 5 == 0) {
        // Every 5 seconds, sync progress
        _syncProgress();
      }
    });
  }

  void _syncProgress() {
    if (_scrollDepth > 0 || _timeSpentSeconds > 0) {
      ref.read(courseRepositoryProvider).logLearningEvent(
        courseId: widget.courseId,
        itemId: widget.moduleId, // Note: The reader is displaying the module. In a real system, you'd track individual content pieces.
        type: 'lesson',
        status: _scrollDepth >= 90 ? 'COMPLETED' : 'IN_PROGRESS',
        timeSpentSeconds: _timeSpentSeconds,
        readingPercentage: _scrollDepth.toInt(),
      );
    }
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    ref.read(playbackControllerProvider.notifier).stopForNavigation();
    super.dispose();
  }

  void _showDisplaySettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Display Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final settings = ref.watch(accessibilityProvider);
                  final notifier = ref.read(accessibilityProvider.notifier);
                  final theme = Theme.of(context);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Font Size Slider
                      Text('Text Size', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.text_decrease, color: theme.colorScheme.onSurfaceVariant),
                          Expanded(
                            child: Slider(
                              value: settings.textScale,
                              min: 0.8,
                              max: 2.5,
                              divisions: 17,
                              label: '${(settings.textScale * 100).toInt()}%',
                              activeColor: theme.colorScheme.primary,
                              inactiveColor: theme.colorScheme.surfaceContainerHighest,
                              onChanged: (val) {
                                notifier.setTextScale(val);
                              },
                            ),
                          ),
                          Icon(Icons.text_increase, color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Font Style (Family)
                      Text('Font Style', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildFontChip('System', 'System', settings.fontFamily, notifier),
                          _buildFontChip('Atkinson', 'Atkinson Hyperlegible', settings.fontFamily, notifier),
                          _buildFontChip('Serif', 'Georgia', settings.fontFamily, notifier),
                          _buildFontChip('Dyslexic', 'OpenDyslexic', settings.fontFamily, notifier),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Font Color (High Contrast / Themes)
                      Text('Color Theme', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildColorThemeCard(
                            title: 'Light',
                            bgColor: const Color(0xFFF5F5F5),
                            textColor: Colors.black,
                            isSelected: !settings.darkMode && !settings.highContrast,
                            onTap: () {
                              if (settings.highContrast) notifier.toggleHighContrast();
                              if (settings.darkMode) notifier.toggleDarkMode();
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildColorThemeCard(
                            title: 'Dark',
                            bgColor: const Color(0xFF1E1E1E),
                            textColor: Colors.white,
                            isSelected: settings.darkMode && !settings.highContrast,
                            onTap: () {
                              if (settings.highContrast) notifier.toggleHighContrast();
                              if (!settings.darkMode) notifier.toggleDarkMode();
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildColorThemeCard(
                            title: 'Contrast',
                            bgColor: Colors.black,
                            textColor: Colors.yellowAccent,
                            isSelected: settings.highContrast,
                            onTap: () {
                              if (!settings.highContrast) notifier.toggleHighContrast();
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontChip(String label, String value, String currentValue, AccessibilityNotifier notifier) {
    final isSelected = currentValue == value || (currentValue == 'System' && value == 'System');
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontFamily: value == 'System' ? null : value)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) notifier.setFontFamily(value);
      },
    );
  }

  Widget _buildColorThemeCard({
    required String title,
    required Color bgColor,
    required Color textColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              'Aa',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackControllerProvider);
    final accessSettings = ref.watch(accessibilityProvider);
    
    final isPolly = accessSettings.ttsEngine == 'polly';
    final currentSpeed = isPolly ? accessSettings.pollySpeed : accessSettings.nativeSpeed;
    final currentPitch = isPolly ? accessSettings.pollyPitch : accessSettings.nativePitch;
    final currentVolume = isPolly ? accessSettings.pollyVolume : accessSettings.nativeVolume;

    final asyncContents = ref.watch(
      moduleContentsProvider((courseId: widget.courseId, moduleId: widget.moduleId)),
    );
    final theme = Theme.of(context);

    return asyncContents.when(
      data: (contents) {
        if (contents.isEmpty) {
          return const Center(child: Text('No content available for this module.'));
        }

        final markdownText = contents.map((c) {
          if (c.contentMarkdown != null) {
            return c.contentMarkdown!;
          } else if (c.type == 'builder' && c.blocks != null) {
            return c.blocks!.map((block) {
              final contentStr = block.content?.toString() ?? '';
              switch (block.type) {
                case 'heading':
                  return '## $contentStr';
                case 'subheading':
                  return '### $contentStr';
                case 'learningObjectives':
                  return '### Learning Objectives\n$contentStr';
                case 'alert':
                  return '> **Important:** $contentStr';
                case 'code':
                  return '```\n$contentStr\n```';
                case 'paragraph':
                default:
                  return contentStr;
              }
            }).join('\n\n');
          }
          return '';
        }).where((text) => text.isNotEmpty).join('\n\n');

        final bgColor = accessSettings.highContrast 
            ? Colors.black 
            : theme.colorScheme.surface;
            
        final textColor = accessSettings.highContrast 
            ? Colors.yellowAccent 
            : theme.colorScheme.onSurface;

        return VisibilityDetector(
          key: Key('reader_${widget.moduleId}'),
          onVisibilityChanged: (VisibilityInfo info) {
            final playback = ref.read(playbackControllerProvider);
            if (info.visibleFraction == 0 && playback.state == PlaybackState.speaking) {
              ref.read(playbackControllerProvider.notifier).pause();
            }
          },
          child: Container(
            color: bgColor,
            child: Column(
              children: [
                // Module Subtitle (Title) and Settings Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppDimensions.marginPage, AppDimensions.marginPage, AppDimensions.marginPage, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Module 3: Backpropagation',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.text_format, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: () => _showDisplaySettingsBottomSheet(context, ref),
                      ),
                    ],
                  ),
                ),
                // Markdown Content or Reading Mode Content
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.maxScrollExtent > 0) {
                        final depth = (scrollInfo.metrics.pixels / scrollInfo.metrics.maxScrollExtent) * 100;
                        if (depth > _scrollDepth) {
                          _scrollDepth = depth;
                        }
                      }
                      return false;
                    },
                    child: playback.state == PlaybackState.speaking 
                      ? _buildReadingMode(context, playback, textColor, accessSettings)
                      : Markdown(
                          data: markdownText,
                          padding: const EdgeInsets.all(AppDimensions.marginPage),
                          styleSheet: MarkdownStyleSheet(
                          h1: theme.textTheme.displayLarge?.copyWith(
                            fontSize: (theme.textTheme.displayLarge?.fontSize ?? 32) * accessSettings.textScale,
                            color: textColor,
                            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
                          ),
                          h2: theme.textTheme.displayMedium?.copyWith(
                            fontSize: (theme.textTheme.displayMedium?.fontSize ?? 28) * accessSettings.textScale,
                            color: textColor,
                            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
                          ),
                          p: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * accessSettings.textScale,
                            color: textColor,
                            height: 1.8,
                            letterSpacing: 0.3,
                            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
                          ),
                          listBullet: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * accessSettings.textScale,
                            color: textColor,
                            height: 1.8,
                            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(50),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          blockquotePadding: const EdgeInsets.all(4),
                          blockquote: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * accessSettings.textScale,
                            color: theme.colorScheme.onPrimaryContainer,
                            height: 1.8,
                            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
                          ),
                        ),
                      ),
                  ),
                ),
                // Audio Player Bottom Bar (Expanding Sheet Panel)
                AnimatedContainer(
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
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Expand/Collapse arrow
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPanelExpanded = !_isPanelExpanded;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isPanelExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Metadata and state row
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${currentSpeed.toStringAsFixed(1)}x',
                              style: TextStyle(
                                color: theme.colorScheme.primary, 
                                fontSize: 12, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Media playback buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_30, size: 36),
                            color: theme.colorScheme.primary,
                            onPressed: () => ref.read(playbackControllerProvider.notifier).skip(-450),
                          ),
                          const SizedBox(width: 32),
                          GestureDetector(
                            onTap: () => ref.read(playbackControllerProvider.notifier).togglePlayPause(markdownText),
                            child: Container(
                              width: 64,
                              height: 64,
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
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          IconButton(
                            icon: const Icon(Icons.forward_30, size: 36),
                            color: theme.colorScheme.primary,
                            onPressed: () => ref.read(playbackControllerProvider.notifier).skip(450),
                          ),
                        ],
                      ),

                      // Settings sliders (expanded panel)
                      if (_isPanelExpanded) ...[
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
                                    // If playing, we need to restart with the new engine
                                    if (playback.state == PlaybackState.speaking || playback.state == PlaybackState.pausedByUser) {
                                      await ref.read(playbackControllerProvider.notifier).stopForNavigation();
                                      await Future.delayed(const Duration(milliseconds: 100));
                                      await ref.read(playbackControllerProvider.notifier).playOrResume(markdownText);
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
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading contents: $e')),
    );
  }

  Widget _buildSettingSlider({
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

  Widget _buildReadingMode(BuildContext context, PlaybackData playback, Color textColor, AccessibilitySettings accessSettings) {
    final text = playback.currentTextToSpeak;
    if (playback.highlightEnd == 0 || playback.highlightEnd > text.length || playback.highlightStart >= playback.highlightEnd) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) * accessSettings.textScale * 1.2,
            color: textColor,
            height: 1.8,
            letterSpacing: 0.5,
            fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
          ),
        ),
      );
    }

    final beforeText = text.substring(0, playback.highlightStart);
    final highlightedWord = text.substring(playback.highlightStart, playback.highlightEnd);
    final afterText = text.substring(playback.highlightEnd);

    final baseStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) * accessSettings.textScale * 1.2,
      color: textColor,
      height: 1.8,
      letterSpacing: 0.5,
      fontFamily: accessSettings.fontFamily == 'System' ? null : accessSettings.fontFamily,
    );

    final highlightStyle = baseStyle?.copyWith(
      backgroundColor: Colors.yellowAccent.shade100,
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.marginPage),
      child: RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: beforeText),
            TextSpan(text: highlightedWord, style: highlightStyle),
            TextSpan(text: afterText),
          ],
        ),
      ),
    );
  }


}
