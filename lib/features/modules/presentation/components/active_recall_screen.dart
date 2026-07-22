import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/shared/models/user_activity.dart';
import 'package:opencampus_lms/features/reader/data/user_activity_repository.dart';
import 'package:opencampus_lms/features/reader/presentation/components/personal_workspace_drawer.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Phase E: Active Recall Screen
///
/// Shows the student their notes and flashcards from the lesson for review,
/// plus a reflection prompt before marking the module complete.
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
    _tabController = TabController(length: 2, vsync: this);
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
    final flashcardsAsync = ref.watch(_flashcardsForModuleProvider(widget.moduleId));
    final cs = Theme.of(context).colorScheme;

    return VisibilityDetector(
      key: Key('active_recall_${widget.moduleId}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text =
              'Active Recall. Review your notes and flashcards from ${widget.module.title}.';
          if (ref.read(currentReadableTextProvider) != text) {
            Future.microtask(
                () => ref.read(currentReadableTextProvider.notifier).state = text);
          }
        }
      },
      child: ReadingModeWrapper(
        child: Column(
          children: [
          _buildTabBar(context, cs),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotesTab(notesAsync, cs),
                  _buildFlashcardsTab(flashcardsAsync, cs),
                ],
              ),
            ),
            _buildReflectionSection(context, cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme cs) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.stackMd,
        AppDimensions.stackMd,
        AppDimensions.stackMd,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackLg,
        vertical: AppDimensions.stackMd,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology_alt_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppDimensions.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Recall',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "Review what you've learned",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.stackMd,
        vertical: AppDimensions.stackSm,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm + 4),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.notes_rounded, size: 18),
            text: 'My Notes',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
          Tab(
            icon: Icon(Icons.style_rounded, size: 18),
            text: 'Flashcards',
            iconMargin: EdgeInsets.only(bottom: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(
      AsyncValue<List<UserNote>> notesAsync, ColorScheme cs) {
    return notesAsync.when(
      data: (notes) {
        if (notes.isEmpty) {
          return _buildEmptyState(
            icon: Icons.notes_rounded,
            title: 'No Notes Yet',
            message:
                'Long-press any text in the lesson\nand tap "Note" to save your thoughts.',
            cs: cs,
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.stackMd,
            AppDimensions.stackSm,
            AppDimensions.stackMd,
            AppDimensions.stackMd,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              _buildNoteCard(notes[index], cs, context),
        );
      },
      loading: () => _buildLoadingState(cs),
      error: (e, _) => _buildErrorState('$e', cs),
    );
  }

  Widget _buildNoteCard(
      UserNote note, ColorScheme cs, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.stackMd, vertical: 10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusLg - 1.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => ref
                      .read(userActivityRepositoryProvider)
                      .deleteNote(note.id),
                  child: Icon(Icons.close_rounded,
                      size: 18, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.stackMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.anchoredText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm + 4),
                      border:
                          Border(left: BorderSide(color: cs.primary, width: 3)),
                    ),
                    child: Text(
                      '"${note.anchoredText!}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackSm),
                ],
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardsTab(
      AsyncValue<List<UserFlashcard>> flashcardsAsync, ColorScheme cs) {
    return flashcardsAsync.when(
      data: (flashcards) {
        if (flashcards.isEmpty) {
          return _buildEmptyState(
            icon: Icons.style_rounded,
            title: 'No Flashcards',
            message:
                'Flashcards will appear here\nonce they are generated for this lesson!',
            cs: cs,
          );
        }
        final card = flashcards[_currentFlashcardIndex];
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.stackMd,
            AppDimensions.stackSm,
            AppDimensions.stackMd,
            AppDimensions.stackMd,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      '${_currentFlashcardIndex + 1} / ${flashcards.length}',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.stackSm),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusFull),
                child: LinearProgressIndicator(
                  value: (_currentFlashcardIndex + 1) / flashcards.length,
                  minHeight: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.stackMd),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(
                      () => _isFlashcardFlipped = !_isFlashcardFlipped),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: _isFlashcardFlipped
                        ? _buildFlashcardFace(
                            key: const ValueKey('answer'),
                            label: 'ANSWER',
                            labelIcon: Icons.lightbulb_rounded,
                            content: card.answer,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            textColor: Colors.white,
                            shadowColor: const Color(0xFF3B82F6),
                          )
                        : _buildFlashcardFace(
                            key: const ValueKey('question'),
                            label: 'QUESTION',
                            labelIcon: Icons.help_outline_rounded,
                            content: card.question,
                            gradient: LinearGradient(
                              colors: [
                                cs.surfaceContainerHigh,
                                cs.surfaceContainerHighest,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            textColor: cs.onSurface,
                            shadowColor: Colors.black,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded,
                      size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to ${_isFlashcardFlipped ? 'hide' : 'reveal'} answer',
                    style:
                        TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.stackMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    onTap: _currentFlashcardIndex > 0
                        ? () => setState(() {
                              _currentFlashcardIndex--;
                              _isFlashcardFlipped = false;
                            })
                        : null,
                    icon: Icons.arrow_back_ios_new_rounded,
                    label: 'Prev',
                    cs: cs,
                  ),
                  if (flashcards.length <= 10)
                    Row(
                      children: List.generate(
                        flashcards.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _currentFlashcardIndex ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _currentFlashcardIndex
                                ? cs.primary
                                : cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull),
                          ),
                        ),
                      ),
                    ),
                  _NavButton(
                    onTap: _currentFlashcardIndex < flashcards.length - 1
                        ? () => setState(() {
                              _currentFlashcardIndex++;
                              _isFlashcardFlipped = false;
                            })
                        : null,
                    icon: Icons.arrow_forward_ios_rounded,
                    label: 'Next',
                    isNext: true,
                    cs: cs,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingState(cs),
      error: (e, _) => _buildErrorState('$e', cs),
    );
  }

  Widget _buildFlashcardFace({
    required Key key,
    required String label,
    required IconData labelIcon,
    required String content,
    required Gradient gradient,
    required Color textColor,
    required Color shadowColor,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.stackLg),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(labelIcon,
                  size: 14, color: textColor.withValues(alpha: 0.7)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackLg),
          Text(
            content,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionSection(BuildContext context, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackMd),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: _reflectionSubmitted
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.green, size: 18),
                ),
                const SizedBox(width: AppDimensions.stackSm),
                Expanded(
                  child: Text(
                    'Reflection saved! Keep scrolling to finish.',
                    style: TextStyle(
                        color: cs.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.record_voice_over_rounded,
                        size: 16, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'What is one thing you learned today?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.stackSm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reflectionController,
                        maxLines: 1,
                        style: TextStyle(fontSize: 14, color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Write your reflection here...',
                          hintStyle: TextStyle(
                              color: cs.onSurfaceVariant, fontSize: 14),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                            borderSide:
                                BorderSide(color: cs.primary, width: 1.5),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        onSubmitted: (_) => _submitReflection(),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.stackSm),
                    FilledButton(
                      onPressed: _submitReflection,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required ColorScheme cs,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.stackLg),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: cs.outlineVariant),
            ),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme cs) {
    return Center(child: CircularProgressIndicator(color: cs.primary));
  }

  Widget _buildErrorState(String error, ColorScheme cs) {
    return Center(
        child: Text('Error: $error',
            style: TextStyle(color: cs.error)));
  }

  void _submitReflection() {
    final text = _reflectionController.text.trim();
    if (text.isEmpty) return;
    // TODO Phase D: Save reflection as a UserNote to Firestore
    setState(() => _reflectionSubmitted = true);
  }
}

/// Navigation button for flashcard prev/next
class _NavButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final bool isNext;
  final ColorScheme cs;

  const _NavButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.cs,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: isNext
                ? [
                    Text(label,
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Icon(icon, size: 14, color: cs.onPrimaryContainer),
                  ]
                : [
                    Icon(icon, size: 14, color: cs.onPrimaryContainer),
                    const SizedBox(width: 6),
                    Text(label,
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600)),
                  ],
          ),
        ),
      ),
    );
  }
}

// Provider for flashcards scoped to this lesson's module
final _flashcardsForModuleProvider =
    StreamProvider.family<List<UserFlashcard>, String>((ref, moduleId) {
  return ref.watch(userActivityRepositoryProvider).watchFlashcards(moduleId);
});
