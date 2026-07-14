import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/widgets/accessible_text.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/reader/providers/reader_state_provider.dart';
import 'package:opencampus_lms/features/reader/widgets/audio_dock.dart';
import 'package:opencampus_lms/core/services/tts_service.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';

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
  late TtsService _ttsService;
  bool _isTextSet = false;

  @override
  void initState() {
    super.initState();
    _ttsService = TtsService();
    Future.microtask(() => _initTts());
  }

  Future<void> _initTts() async {
    final available = await _ttsService.init();
    ref.read(readerStateProvider.notifier).setTtsAvailable(available);
    
    _ttsService.setProgressHandler((text, start, end, word) {
      ref.read(readerStateProvider.notifier).updateHighlight(start, end);
    });

    _ttsService.setCompletionHandler(() {
      ref.read(readerStateProvider.notifier).setPlaying(false);
      ref.read(readerStateProvider.notifier).updateHighlight(0, 0);
    });
  }

  @override
  void dispose() {
    _ttsService.stop();
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
            return const Center(child: Text('No content available.'));
          }

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

          // Clean up markdown for better TTS reading
          final cleanText = rawText.replaceAll(RegExp(r'[#*`>]'), '').trim();

          // Set the text for TTS once when loaded
          if (!_isTextSet && cleanText.isNotEmpty) {
            Future.microtask(() {
              ref.read(readerStateProvider.notifier).setText(cleanText);
              if (mounted) {
                setState(() {
                  _isTextSet = true;
                });
              }
            });
          }

          final text = cleanText;
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading content: $err')),
      ),
      bottomNavigationBar: AudioDock(ttsService: _ttsService),
    );
  }
}
