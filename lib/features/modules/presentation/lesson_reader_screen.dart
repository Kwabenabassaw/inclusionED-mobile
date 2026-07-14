import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import '../../lessons/presentation/components/audio_toolbar.dart';
import '../../lessons/presentation/controllers/audio_player_controller.dart';

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
        title: Text('Lesson Reader'),
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

          final markdownText = contents
              .where((c) => c.contentMarkdown != null)
              .map((c) => c.contentMarkdown)
              .join('\n\n');

          return Column(
            children: [
              Expanded(
                child: Markdown(
                  data: markdownText,
                  padding: const EdgeInsets.all(AppDimensions.marginPage),
                  styleSheet: MarkdownStyleSheet(
                    h1: Theme.of(context).textTheme.displayLarge,
                    h2: Theme.of(context).textTheme.displayMedium,
                    p: Theme.of(context).textTheme.bodyLarge,
                    listBullet: Theme.of(context).textTheme.bodyLarge,
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
