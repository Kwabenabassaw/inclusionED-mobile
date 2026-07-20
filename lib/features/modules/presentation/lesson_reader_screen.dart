import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import '../../lessons/presentation/components/audio_toolbar.dart';
import '../../lessons/presentation/controllers/audio_player_controller.dart';
import '../../reader/presentation/components/selection_toolbar.dart';
import '../../reader/presentation/components/personal_workspace_drawer.dart';
import '../../reader/presentation/components/add_note_bottom_sheet.dart';
import '../../reader/presentation/utils/highlight_markdown_extension.dart';
import '../../reader/data/user_activity_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:opencampus_lms/shared/models/user_activity.dart';
import 'package:markdown/markdown.dart' as md;

class LessonReaderScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;

  const LessonReaderScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<LessonReaderScreen> createState() => _LessonReaderScreenState();
}

class _LessonReaderScreenState extends ConsumerState<LessonReaderScreen> {
  @override
  void dispose() {
    Future.microtask(() => ref.read(audioPlayerControllerProvider.notifier).pause());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncContents = ref.watch(
      moduleContentsProvider((courseId: widget.courseId, moduleId: widget.moduleId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Reader'),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu_book),
                tooltip: 'Open Learning Hub',
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            }
          ),
        ],
      ),
      endDrawer: PersonalWorkspaceDrawer(
        moduleId: widget.moduleId,
        courseId: widget.courseId,
      ),
      body: asyncContents.when(
        data: (contents) {
          if (contents.isEmpty) {
            return Center(
              child: Semantics(
                label: 'No content available for this module.',
                child: Text('No content available for this module.'),
              ),
            );
          }

          var markdownText = contents
              .where((c) => c.contentMarkdown != null)
              .map((c) => c.contentMarkdown)
              .join('\n\n');

          // Inject Highlights
          final highlightsAsync = ref.watch(userHighlightsProvider(widget.moduleId));
          if (highlightsAsync.hasValue) {
            final highlights = highlightsAsync.value!;
            for (var highlight in highlights) {
              // Wrap the original highlighted string in our custom ==syntax==
              // We only want to replace the first occurrence that matches exactly, or use the startIndex/endIndex
              // For simplicity, we just replace the text
              markdownText = markdownText.replaceAll(
                highlight.text,
                '==\${highlight.text}::\${highlight.colorHex}=='
              );
            }
          }

          return Column(
            children: [
              Expanded(
                child: SelectionArea(
                  contextMenuBuilder: (BuildContext context, SelectableRegionState selectableRegionState) {
                    // ignore: deprecated_member_use
                    final selectedText = selectableRegionState.textEditingValue.selection.textInside(selectableRegionState.textEditingValue.text);
                    return SelectionToolbar.buildContextMenu(
                      context: context,
                      selectableRegionState: selectableRegionState,
                      selectedText: selectedText,
                      onHighlight: () async {
                        // Generate a random color or pick from a palette
                        final colors = ['#FFFF00', '#00FF00', '#00FFFF', '#FF00FF'];
                        final randomColor = colors[Random().nextInt(colors.length)];
                        
                        final highlight = UserHighlight(
                          id: const Uuid().v4(),
                          lessonId: widget.moduleId,
                          courseId: widget.courseId,
                          text: selectedText,
                          startIndex: 0, // In a real app we'd map this to the exact span offset
                          endIndex: selectedText.length,
                          colorHex: randomColor,
                          createdAt: DateTime.now(),
                        );
                        
                        await ref.read(userActivityRepositoryProvider).saveHighlight(highlight);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Highlight saved!'),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(bottom: 120, left: 16, right: 16),
                          ));
                        }
                      },
                      onAddNote: () {
                        AddNoteBottomSheet.show(
                          context: context,
                          moduleId: widget.moduleId,
                          courseId: widget.courseId,
                          anchoredText: selectedText,
                        );
                      },
                      onAskAi: () {
                        // TODO: Route to AI Companion with context
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Asking AI about: "\$selectedText"'),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
                        ));
                      },
                    );
                  },
                  child: Markdown(
                    data: markdownText,
                    padding: const EdgeInsets.all(AppDimensions.marginPage),
                    extensionSet: md.ExtensionSet(
                      md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                      [
                        ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
                        HighlightSyntax(),
                      ],
                    ),
                    builders: {
                      'highlight': HighlightBuilder(),
                    },
                    styleSheet: MarkdownStyleSheet(
                      h1: Theme.of(context).textTheme.displayLarge,
                      h2: Theme.of(context).textTheme.displayMedium,
                      p: Theme.of(context).textTheme.bodyLarge,
                      listBullet: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
              AudioToolbar(
                lessonId: widget.moduleId,
                lessonText: markdownText,
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Semantics(
            label: 'Error loading contents: $e',
            child: Text('Error loading contents: $e'),
          ),
        ),
      ),
    );
  }
}
