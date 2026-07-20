import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/shared/models/user_activity.dart';
import 'package:opencampus_lms/features/reader/presentation/components/personal_workspace_drawer.dart';
import 'package:opencampus_lms/features/reader/data/user_activity_repository.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Phase E: Active Recall Screen
///
/// This screen sits between the summary and completion pages.
/// It shows the student their notes and highlights from the lesson,
/// presents their flashcards in a review format, and asks them a
/// reflection question before marking the module complete.
class ActiveRecallScreen extends ConsumerStatefulWidget {
  final Module module;
  final String courseId;
  final String moduleId;

  const ActiveRecallScreen({
    super.key,
    required this.module,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<ActiveRecallScreen> createState() => _ActiveRecallScreenState();
}

class _ActiveRecallScreenState extends ConsumerState<ActiveRecallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _reflectionController = TextEditingController();
  bool _reflectionSubmitted = false;
  int _currentFlashcardIndex = 0;
  bool _isFlashcardFlipped = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(userNotesProvider(widget.moduleId));
    final highlightsAsync = ref.watch(userHighlightsProvider(widget.moduleId));
    final flashcardsAsync = ref.watch(_flashcardsForModuleProvider(widget.moduleId));

    return VisibilityDetector(
      key: Key('active_recall_${widget.moduleId}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text =
              'Active Recall. Review your notes, highlights, and flashcards from ${widget.module.title}.';
          if (ref.read(currentReadableTextProvider) != text) {
            Future.microtask(
                () => ref.read(currentReadableTextProvider.notifier).state = text);
          }
        }
      },
      child: ReadingModeWrapper(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(context),

            // ── Tab Bar ─────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.notes), text: 'Notes'),
                Tab(icon: Icon(Icons.highlight), text: 'Highlights'),
                Tab(icon: Icon(Icons.quiz_outlined), text: 'Flashcards'),
              ],
            ),

            // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Notes Tab
                  _buildNotesTab(notesAsync),
                  // Highlights Tab
                  _buildHighlightsTab(highlightsAsync),
                  // Flashcards Tab
                  _buildFlashcardsTab(flashcardsAsync),
                ],
              ),
            ),

            // ── Reflection Section ────────────────────────────────────────
            _buildReflectionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.stackLg),
      margin: const EdgeInsets.all(AppDimensions.stackMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.stackSm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology_alt,
              size: 32,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppDimensions.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Recall',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  'Review what you\'ve learned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(AsyncValue<List<UserNote>> notesAsync) {
    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.notes,
            message: 'No notes from this lesson.\nTry selecting text and tapping "Add Note" next time!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.stackMd),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.stackMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.notes,
                            size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: AppDimensions.stackSm),
                        Expanded(
                          child: Text(
                            note.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
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
                          border: Border(
                            left: BorderSide(
                                color: Theme.of(context).colorScheme.primary, width: 3),
                          ),
                        ),
                        child: Text(
                          '"${note.anchoredText!}"',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimensions.stackSm),
                    Text(note.content, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildHighlightsTab(AsyncValue<List<UserHighlight>> highlightsAsync) {
    return highlightsAsync.when(
      data: (highlights) {
        if (highlights.isEmpty) {
          return _buildEmptyState(
            icon: Icons.highlight,
            message:
                'No highlights from this lesson.\nTry selecting text and tapping "Highlight" next time!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppDimensions.stackMd),
          itemCount: highlights.length,
          itemBuilder: (context, index) {
            final highlight = highlights[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
              clipBehavior: Clip.hardEdge,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: _parseColor(highlight.colorHex),
                      width: 5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(AppDimensions.stackMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: _parseColor(highlight.colorHex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.stackSm),
                    Expanded(
                      child: Text(
                        highlight.text,
                        style: Theme.of(context).textTheme.bodyMedium,
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
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFlashcardsTab(AsyncValue<List<UserFlashcard>> flashcardsAsync) {
    return flashcardsAsync.when(
      data: (flashcards) {
        if (flashcards.isEmpty) {
          return _buildEmptyState(
            icon: Icons.quiz_outlined,
            message: 'No flashcards yet.\nFlashcards will appear here after they\'re generated!',
          );
        }

        final card = flashcards[_currentFlashcardIndex];

        return Padding(
          padding: const EdgeInsets.all(AppDimensions.stackMd),
          child: Column(
            children: [
              // Progress indicator
              Text(
                'Card ${_currentFlashcardIndex + 1} of ${flashcards.length}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              LinearProgressIndicator(
                value: (_currentFlashcardIndex + 1) / flashcards.length,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: AppDimensions.stackLg),

              // Flashcard (Flip animation)
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFlashcardFlipped = !_isFlashcardFlipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isFlashcardFlipped
                        ? _buildFlashcardFace(
                            key: const ValueKey('answer'),
                            context: context,
                            label: 'ANSWER',
                            content: card.answer,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            textColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          )
                        : _buildFlashcardFace(
                            key: const ValueKey('question'),
                            context: context,
                            label: 'QUESTION',
                            content: card.question,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            textColor: Theme.of(context).colorScheme.onSurface,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.stackSm),
              Text(
                'Tap card to ${_isFlashcardFlipped ? 'hide' : 'reveal'} answer',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppDimensions.stackLg),

              // Prev / Next buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: _currentFlashcardIndex > 0
                        ? () => setState(() {
                              _currentFlashcardIndex--;
                              _isFlashcardFlipped = false;
                            })
                        : null,
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: AppDimensions.stackLg),
                  FilledButton.tonal(
                    onPressed: _currentFlashcardIndex < flashcards.length - 1
                        ? () => setState(() {
                              _currentFlashcardIndex++;
                              _isFlashcardFlipped = false;
                            })
                        : null,
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildFlashcardFace({
    required Key key,
    required BuildContext context,
    required String label,
    required String content,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.stackLg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.stackLg),
          Text(
            content,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _reflectionSubmitted
          ? Row(
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppDimensions.stackSm),
                Expanded(
                  child: Text(
                    'Reflection saved! Keep scrolling to finish the lesson.',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💭 What is one thing you learned today?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reflectionController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Write your reflection here...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onSubmitted: (_) => _submitReflection(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.stackSm),
                    FilledButton(
                      onPressed: _submitReflection,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitReflection() {
    final text = _reflectionController.text.trim();
    if (text.isEmpty) return;
    // TODO Phase D: Save reflection as a UserNote to Firestore
    setState(() => _reflectionSubmitted = true);
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.yellow;
    }
  }
}

// Provider for flashcards scoped to this lesson's module
// (Flashcards can span a whole course — for the recall screen we show all course flashcards)
final _flashcardsForModuleProvider =
    StreamProvider.family<List<UserFlashcard>, String>((ref, moduleId) {
  // We watch by lessonId since UserFlashcard has a lessonId field
  return ref.watch(userActivityRepositoryProvider).watchFlashcards(moduleId);
});
