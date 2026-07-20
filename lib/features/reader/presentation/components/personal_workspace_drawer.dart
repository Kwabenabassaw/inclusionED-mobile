import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/user_activity.dart';
import '../../data/user_activity_repository.dart';
import 'package:opencampus_lms/core/utils/color_extension.dart';

class PersonalWorkspaceDrawer extends ConsumerWidget {
  final String moduleId;
  final String courseId;

  const PersonalWorkspaceDrawer({
    super.key,
    required this.moduleId,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppDimensions.marginPage,
                bottom: AppDimensions.stackMd,
                left: AppDimensions.marginPage,
                right: AppDimensions.marginPage,
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.onPrimaryContainer),
                      const SizedBox(width: AppDimensions.stackSm),
                      Text(
                        'Learning Hub',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  TabBar(
                    labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Notes'),
                      Tab(text: 'Highlights'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _NotesTab(moduleId: moduleId),
                  _HighlightsTab(moduleId: moduleId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends ConsumerWidget {
  final String moduleId;

  const _NotesTab({required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(userNotesProvider(moduleId));

    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              child: Text(
                'No notes yet. Select text in the lesson to add a note!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.stackMd),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.stackMd),
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.stackMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () {
                            ref.read(userActivityRepositoryProvider).deleteNote(note.id);
                          },
                        ),
                      ],
                    ),
                    if (note.anchoredText != null) ...[
                      const SizedBox(height: AppDimensions.stackSm),
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.stackSm),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '"\${note.anchoredText!}"',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.stackMd),
                    Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: AppDimensions.stackMd),
                    Text(
                      DateFormat.yMMMd().format(note.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: \$e')),
    );
  }
}

class _HighlightsTab extends ConsumerWidget {
  final String moduleId;

  const _HighlightsTab({required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(userHighlightsProvider(moduleId));

    return highlightsAsync.when(
      data: (highlights) {
        if (highlights.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              child: Text(
                'No highlights yet. Select text in the lesson to highlight it!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppDimensions.stackMd),
          itemCount: highlights.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.stackMd),
          itemBuilder: (context, index) {
            final highlight = highlights[index];
            final color = HexColor.fromHex(highlight.colorHex);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.stackMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              highlight.text,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(userActivityRepositoryProvider).deleteHighlight(highlight.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.stackSm),
                      Text(
                        DateFormat.yMMMd().format(highlight.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: \$e')),
    );
  }
}

// StateProviders to bridge streams
final userNotesProvider = StreamProvider.family<List<UserNote>, String>((ref, moduleId) {
  return ref.watch(userActivityRepositoryProvider).watchNotes(moduleId);
});

final userHighlightsProvider = StreamProvider.family<List<UserHighlight>, String>((ref, moduleId) {
  return ref.watch(userActivityRepositoryProvider).watchHighlights(moduleId);
});
