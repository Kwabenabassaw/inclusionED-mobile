import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/user_activity.dart';
import '../../data/user_activity_repository.dart';
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/features/gamification/presentation/xp_celebration_overlay.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

class AddNoteBottomSheet extends ConsumerStatefulWidget {
  final String moduleId;
  final String courseId;
  final String? anchoredText;

  const AddNoteBottomSheet({
    super.key,
    required this.moduleId,
    required this.courseId,
    this.anchoredText,
  });

  static Future<void> show({
    required BuildContext context,
    required String moduleId,
    required String courseId,
    String? anchoredText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLg)),
      ),
      builder: (context) => AddNoteBottomSheet(
        moduleId: moduleId,
        courseId: courseId,
        anchoredText: anchoredText,
      ),
    );
  }

  @override
  ConsumerState<AddNoteBottomSheet> createState() => _AddNoteBottomSheetState();
}

class _AddNoteBottomSheetState extends ConsumerState<AddNoteBottomSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and content for your note.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(userActivityRepositoryProvider);
      final note = UserNote(
        id: const Uuid().v4(),
        lessonId: widget.moduleId,
        courseId: widget.courseId,
        title: title,
        content: content,
        anchoredText: widget.anchoredText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveNote(note);

      // Award Gamification XP for note taking
      if (mounted) {
        try {
          final result = await ref.read(gamificationRepositoryProvider).awardXp(
            XpEvent.addedNote,
            noteAdded: true,
          );

          if (!mounted) return;

          Navigator.of(context).pop();

          if (result.leveledUp || result.newBadges.isNotEmpty) {
            await XpCelebrationOverlay.show(
              context,
              newLevel: result.stats.level,
              xpAwarded: XpEvent.addedNote,
              newBadges: result.newBadges,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: XpToast(xp: XpEvent.addedNote, label: 'Note added!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                elevation: 0,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Gamification error: $e');
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Note saved successfully!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the bottom padding needed for the keyboard
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.marginPage,
        right: AppDimensions.marginPage,
        top: AppDimensions.marginPage,
        bottom: bottomInset + AppDimensions.marginPage,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Note',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackLg),
          if (widget.anchoredText != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.stackMd),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppDimensions.stackSm),
                  Expanded(
                    child: Text(
                      widget.anchoredText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.stackLg),
          ],
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Note Title',
              hintText: 'e.g. Important definition',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppDimensions.stackMd),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Your Note',
              hintText: 'Write your thoughts here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppDimensions.stackLg),
          FilledButton(
            onPressed: _isSaving ? null : _saveNote,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Note'),
          ),
        ],
      ),
    );
  }
}
