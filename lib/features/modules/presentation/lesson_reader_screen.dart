import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/features/gamification/presentation/xp_celebration_overlay.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';
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
            
            // 1. Map each highlight to its absolute range in the original markdownText
            List<Map<String, dynamic>> replacements = [];
            for (var highlight in highlights) {
              int currentIndex = 0;
              int searchStart = 0;
              int foundIndex = -1;
              
              while (currentIndex <= highlight.startIndex) {
                foundIndex = markdownText.indexOf(highlight.text, searchStart);
                if (foundIndex == -1) break;
                searchStart = foundIndex + highlight.text.length;
                currentIndex++;
              }
              
              if (foundIndex != -1) {
                replacements.add({
                  'start': foundIndex,
                  'end': foundIndex + highlight.text.length,
                  'text': highlight.text,
                  'color': highlight.colorHex,
                });
              }
            }

            // 2. Sort replacements by start index descending!
            replacements.sort((a, b) => (b['start'] as int).compareTo(a['start'] as int));

            // 3. Apply replacements from back to front
            for (var rep in replacements) {
              markdownText = markdownText.replaceRange(
                rep['start'] as int,
                rep['end'] as int,
                "==${rep['text']}::${rep['color']}=="
              );
            }
          }

          return Column(
            children: [
              Expanded(
                child: Markdown(
                  data: markdownText,
                  padding: const EdgeInsets.all(AppDimensions.marginPage),
                  selectable: true,
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
                  contextMenuBuilder: (BuildContext menuContext, EditableTextState editableTextState) {
                    return SelectionToolbar.buildContextMenu(
                      context: menuContext,
                      editableTextState: editableTextState,
                      onHighlight: (selectedText, occurrenceIndex) async {
                        if (selectedText.isEmpty) return;
                        // Generate a random color from palette
                        final colors = ['#FFFF00', '#00FF00', '#00FFFF', '#FF00FF'];
                        final randomColor = colors[Random().nextInt(colors.length)];

                        final highlight = UserHighlight(
                          id: const Uuid().v4(),
                          lessonId: widget.moduleId,
                          courseId: widget.courseId,
                          text: selectedText,
                          startIndex: occurrenceIndex,
                          endIndex: occurrenceIndex,
                          colorHex: randomColor,
                          createdAt: DateTime.now(),
                        );

                        await ref.read(userActivityRepositoryProvider).saveHighlight(highlight);

                        // Award XP
                        try {
                          final result = await ref.read(gamificationRepositoryProvider).awardXp(
                            XpEvent.addedHighlight,
                            highlightAdded: true,
                          );

                          if (!context.mounted) return;

                          if (result.leveledUp || result.newBadges.isNotEmpty) {
                            await XpCelebrationOverlay.show(
                              context,
                              newLevel: result.stats.level,
                              xpAwarded: XpEvent.addedHighlight,
                              newBadges: result.newBadges,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: XpToast(xp: XpEvent.addedHighlight, label: 'Highlight saved!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 120, left: 16, right: 16),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Gamification error: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Highlight saved!'),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.only(bottom: 120, left: 16, right: 16),
                            ));
                          }
                        }
                      },
                      onAddNote: (selectedText) {
                        AddNoteBottomSheet.show(
                          context: context,
                          moduleId: widget.moduleId,
                          courseId: widget.courseId,
                          anchoredText: selectedText,
                        );
                      },
                      onAskAi: (selectedText) {
                        final encodedPrompt = Uri.encodeComponent('Can you explain this concept to me: "$selectedText"');
                        context.push('/assistant?courseId=${widget.courseId}&initialPrompt=$encodedPrompt');
                      },
                    );
                  },
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
