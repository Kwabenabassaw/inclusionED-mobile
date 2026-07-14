import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/widgets/accessible_text.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/reader/providers/reader_state_provider.dart';
import 'package:opencampus_lms/features/reader/widgets/audio_dock.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';

import 'package:opencampus_lms/core/utils/text_normalizer.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';

class AccessibleReaderScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;

  const AccessibleReaderScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<AccessibleReaderScreen> createState() => _AccessibleReaderScreenState();
}

class _AccessibleReaderScreenState extends ConsumerState<AccessibleReaderScreen> {
  bool _isTextSet = false;

  @override
  void initState() {
    super.initState();
    // TTS engine initialisation is handled exclusively by PlaybackController.
    // No local TtsService instance is needed.
  }

  @override
  void dispose() {
    // Route all teardown through the authoritative state machine so that
    // PlaybackController's internal FlutterTts / AudioPlayer are stopped in
    // a consistent, tracked state.
    ref.read(playbackControllerProvider.notifier).stopForNavigation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerStateProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);

    final asyncContents = ref.watch(
      moduleContentsProvider((courseId: widget.courseId, moduleId: widget.moduleId)),
    );

    return Scaffold(
      body: asyncContents.when(
        data: (contents) {
          if (contents.isEmpty) {
            return Center(child: Text('No content available.'));
          }

          // Build the raw markdown text — this is the display text shown on screen.
          final rawText = contents.map((c) {
            if (c.contentMarkdown != null) {
              return c.contentMarkdown!;
            } else if (c.type == 'builder' && c.blocks != null) {
              return c.blocks!.map((block) {
                if (block.type == 'image') {
                  final altText = block.metadata?['altText'] as String? ?? 'Image';
                  return 'Image description: $altText.';
                } else if (block.type == 'video') {
                  return 'There is an embedded video here.';
                }
                return block.content?.toString() ?? '';
              }).join(' ');
            }
            return '';
          }).where((text) => text.isNotEmpty).join('\n\n');

          // Produce a TTS-friendly version (markdown stripped) and the
          // index map that aligns clean indices back to raw positions.
          // speechText is ONLY sent to the engine — it is never rendered.
          final cleanText = TextNormalizer.normalizeForSpeech(rawText).cleanText;

          // Populate ReaderState once when content first loads.
          if (!_isTextSet && rawText.isNotEmpty) {
            Future.microtask(() {
              ref.read(readerStateProvider.notifier).setText(
                displayText: rawText,   // rendered on screen — retains markdown
                speechText: cleanText,  // spoken by engine — markdown stripped
              );
              if (mounted) {
                setState(() {
                  _isTextSet = true;
                });
              }
            });
          }

          // Render displayText (rawText) on screen so markdown formatting
          // is preserved for sighted users. Highlight offsets are mapped
          // back to raw positions via _textIndexMap inside PlaybackController.
          final text = rawText;
          final int start = readerState.highlightStart;
          final int end = readerState.highlightEnd;

          final safeStart = start.clamp(0, text.length);
          final safeEnd = end.clamp(safeStart, text.length);

          final baseStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
          final normalStyle = baseStyle.copyWith(
            fontSize: 18 * accessibilitySettings.textScale,
            height: accessibilitySettings.lineSpacing,
            color: Theme.of(context).colorScheme.onSurface,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const AccessibleText('Accessible Reader'),
                  background: Hero(
                    tag: 'course_cover_${widget.courseId}',
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      alignment: Alignment.center,
                      child: Icon(Icons.school, size: 64, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: RichText(
                    textScaler: TextScaler.linear(accessibilitySettings.textScale),
                    text: TextSpan(
                      style: normalStyle,
                      children: [
                        TextSpan(text: text.substring(0, safeStart)),
                        TextSpan(
                          text: text.substring(safeStart, safeEnd),
                          style: normalStyle.copyWith(
                            backgroundColor: Colors.yellow,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(text: text.substring(safeEnd)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading content: $err')),
      ),
      bottomNavigationBar: const AudioDock(),
    );
  }
}
