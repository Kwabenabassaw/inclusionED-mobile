import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';

import 'package:visibility_detector/visibility_detector.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'playback_controller.dart';

import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';

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
  double _scrollDepth = 0.0;
  int _timeSpentSeconds = 0;
  Timer? _trackingTimer;
  late final PlaybackController _playbackController;

  @override
  void initState() {
    super.initState();
    _playbackController = ref.read(playbackControllerProvider.notifier);

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
      ref
          .read(courseRepositoryProvider)
          .logLearningEvent(
            courseId: widget.courseId,
            itemId: widget
                .moduleId, // Note: The reader is displaying the module. In a real system, you'd track individual content pieces.
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
    _playbackController.stopForNavigation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = ref.watch(playbackControllerProvider);
    final accessSettings = ref.watch(accessibilityProvider);

    final asyncContents = ref.watch(
      moduleContentsProvider((
        courseId: widget.courseId,
        moduleId: widget.moduleId,
      )),
    );
    final theme = Theme.of(context);

    return asyncContents.when(
      data: (contents) {
        if (contents.isEmpty) {
          return Center(
            child: Text('No content available for this module.'),
          );
        }

        final markdownText = contents
            .map((c) {
              if (c.contentMarkdown != null) {
                return c.contentMarkdown!;
              } else if (c.type == 'builder' && c.blocks != null) {
                return c.blocks!
                    .map((block) {
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
                        case 'image':
                          final altText =
                              block.metadata?['altText'] as String? ?? 'Image';
                          return '![$altText]($contentStr)';
                        case 'video':
                          return '[📺 Watch Video on YouTube]($contentStr)';
                        case 'paragraph':
                        default:
                          return contentStr;
                      }
                    })
                    .join('\n\n');
              }
              return '';
            })
            .where((text) => text.isNotEmpty)
            .join('\n\n');

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
            if (info.visibleFraction == 0 &&
                playback.state == PlaybackState.speaking) {
              ref.read(playbackControllerProvider.notifier).pause();
            } else if (info.visibleFraction > 0.5) {
              if (ref.read(currentReadableTextProvider) != markdownText) {
                Future.microtask(
                  () => ref.read(currentReadableTextProvider.notifier).state =
                      markdownText,
                );
              }
            }
          },
          child: Container(
            color: bgColor,
            child: Column(
              children: [
                // Module Subtitle (Title) and Settings Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.marginPage,
                    AppDimensions.marginPage,
                    AppDimensions.marginPage,
                    0,
                  ),
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
                    ],
                  ),
                ),
                // Markdown Content or Reading Mode Content
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.maxScrollExtent > 0) {
                        final depth =
                            (scrollInfo.metrics.pixels /
                                scrollInfo.metrics.maxScrollExtent) *
                            100;
                        if (depth > _scrollDepth) {
                          _scrollDepth = depth;
                        }
                      }
                      return false;
                    },
                    child: ReadingModeWrapper(
                      child: Markdown(
                        data: markdownText,
                        padding: const EdgeInsets.all(AppDimensions.marginPage),
                        styleSheet: MarkdownStyleSheet(
                          h1: theme.textTheme.displayLarge?.copyWith(
                            fontSize:
                                (theme.textTheme.displayLarge?.fontSize ?? 32) *
                                accessSettings.textScale,
                            color: textColor,
                            height: accessSettings.lineSpacing,
                            fontFamily: accessSettings.fontFamily == 'System'
                                ? null
                                : accessSettings.fontFamily,
                            fontWeight: accessSettings.boldText
                                ? FontWeight.w900
                                : FontWeight.bold,
                          ),
                          h2: theme.textTheme.displayMedium?.copyWith(
                            fontSize:
                                (theme.textTheme.displayMedium?.fontSize ??
                                    28) *
                                accessSettings.textScale,
                            color: textColor,
                            height: accessSettings.lineSpacing,
                            fontFamily: accessSettings.fontFamily == 'System'
                                ? null
                                : accessSettings.fontFamily,
                            fontWeight: accessSettings.boldText
                                ? FontWeight.w900
                                : FontWeight.bold,
                          ),
                          p: theme.textTheme.bodyLarge?.copyWith(
                            fontSize:
                                (theme.textTheme.bodyLarge?.fontSize ?? 16) *
                                accessSettings.textScale,
                            color: textColor,
                            height: accessSettings.lineSpacing * 1.5,
                            letterSpacing: 0.3,
                            fontFamily: accessSettings.fontFamily == 'System'
                                ? null
                                : accessSettings.fontFamily,
                            fontWeight: accessSettings.boldText
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          listBullet: theme.textTheme.bodyLarge?.copyWith(
                            fontSize:
                                (theme.textTheme.bodyLarge?.fontSize ?? 16) *
                                accessSettings.textScale,
                            color: textColor,
                            height: accessSettings.lineSpacing * 1.5,
                            fontFamily: accessSettings.fontFamily == 'System'
                                ? null
                                : accessSettings.fontFamily,
                            fontWeight: accessSettings.boldText
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              50,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          blockquotePadding: const EdgeInsets.all(4),
                          blockquote: theme.textTheme.bodyLarge?.copyWith(
                            fontSize:
                                (theme.textTheme.bodyLarge?.fontSize ?? 16) *
                                accessSettings.textScale,
                            color: theme.colorScheme.onPrimaryContainer,
                            height: accessSettings.lineSpacing * 1.5,
                            fontFamily: accessSettings.fontFamily == 'System'
                                ? null
                                : accessSettings.fontFamily,
                            fontWeight: accessSettings.boldText
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading contents: $e')),
    );
  }
}
