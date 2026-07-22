import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/core/theme/app_theme.dart';
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/features/gamification/presentation/xp_celebration_overlay.dart';
import 'package:opencampus_lms/shared/models/quiz.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

class QuizResultsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final Quiz quiz;
  final Map<int, String> studentAnswers;
  
  const QuizResultsScreen({
    super.key,
    required this.courseId,
    required this.quiz,
    required this.studentAnswers,
  });

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen> {
  bool _xpAwarded = false;

  @override
  void initState() {
    super.initState();
    // Award XP after the first frame so context/overlay is available
    WidgetsBinding.instance.addPostFrameCallback((_) => _awardQuizXp());
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final q = widget.quiz.questions[i];
      final answer = widget.studentAnswers[i] ?? '';
      if (answer.toLowerCase().trim() == q.correctAnswer.toLowerCase().trim()) {
        score += q.points;
      }
    }
    return score;
  }

  Future<void> _awardQuizXp() async {
    if (_xpAwarded || !mounted) return;
    _xpAwarded = true;

    final score = _calculateScore();
    final percentage =
        widget.quiz.totalPoints > 0 ? (score / widget.quiz.totalPoints) * 100 : 0.0;
    final isPerfect = percentage >= 100.0;

    final baseXp = XpEvent.completedQuiz + (isPerfect ? XpEvent.perfectQuiz : 0);

    try {
      final result = await ref.read(gamificationRepositoryProvider).awardXp(
        baseXp,
        // quizAce badge is checked inside awardXp via earnedSet — we signal via
        // a custom flag by temporarily patching the stats check in the repo.
        // Since awardXp already checks isPerfect through the quizAce badge
        // condition we force-add it here by calling with a direct helper.
      );

      // quizAce badge: award separately if perfect and not yet earned
      List<BadgeId> allNewBadges = List.from(result.newBadges);
      if (isPerfect) {
        final earnedIds = Set<String>.from(result.stats.earnedBadgeIds);
        if (!earnedIds.contains(BadgeId.quizAce.name)) {
          // Award the badge by re-saving with quizAce added
          final updatedIds = [...earnedIds, BadgeId.quizAce.name];
          final updatedStats = result.stats.copyWith(earnedBadgeIds: updatedIds);
          await ref.read(gamificationRepositoryProvider).save(updatedStats);
          allNewBadges.add(BadgeId.quizAce);
        }
      }

      if (!mounted) return;

      if (result.leveledUp || allNewBadges.isNotEmpty) {
        await XpCelebrationOverlay.show(
          context,
          newLevel: result.stats.level,
          xpAwarded: baseXp,
          newBadges: allNewBadges,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: XpToast(
              xp: baseXp,
              label: isPerfect ? 'Perfect Score! 🏆' : 'Quiz complete!',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gamification quiz award error: $e');
    }
  }


  int _calculateCorrectCount() {
    int count = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      final q = widget.quiz.questions[i];
      final answer = widget.studentAnswers[i] ?? '';
      if (answer.toLowerCase().trim() == q.correctAnswer.toLowerCase().trim()) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AccessibilityThemeExtension>();
    final score = _calculateScore();
    final correctCount = _calculateCorrectCount();
    final percentage = widget.quiz.totalPoints > 0 ? (score / widget.quiz.totalPoints) * 100 : 0.0;
    final isPassed = percentage >= 60.0;
    final isPerfect = percentage >= 100.0;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Quiz Results'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/achievements'),
            icon: const Text('⭐', style: TextStyle(fontSize: 14)),
            label: const Text('XP'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.marginPage,
            vertical: AppDimensions.stackMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- TOP SCORE CARD (ACCESSIBLE & MODERN) ---
              Semantics(
                label: 'Quiz result summary: You scored $score out of ${widget.quiz.totalPoints} points. Percentage: ${percentage.toStringAsFixed(0)}%. ${isPassed ? "You passed!" : "You can try again."}${isPerfect ? " Perfect score!" : ""}',
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.stackLg),
                    child: Column(
                      children: [
                        // Circular score visualization for visual learners
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 10,
                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                color: isPerfect
                                    ? Colors.amber
                                    : isPassed
                                        ? (ext?.quizCorrectColor ?? Colors.green.shade600)
                                        : theme.colorScheme.primary,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '$score / ${widget.quiz.totalPoints} pts',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.stackLg),
                        Text(
                          isPerfect
                              ? '🏆 Perfect Score!'
                              : isPassed
                                  ? 'Congratulations! You Passed'
                                  : 'Keep Learning!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isPerfect ? Colors.amber.shade700 : theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppDimensions.stackSm),
                        Text(
                          'You correctly answered $correctCount out of ${widget.quiz.questions.length} questions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.stackLg),
              
              // --- XP EARNED CHIP ---
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade600, width: 1.5),
                  ),
                  child: Text(
                    '+${XpEvent.completedQuiz + (isPerfect ? XpEvent.perfectQuiz : 0)} XP Earned${isPerfect ? "  •  🏆 Quiz Ace Badge!" : ""}',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.stackLg),

              // --- REVIEW SECTION HEADER ---
              Text(
                'Review Answers',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.stackMd),

              // --- ANSWERS LIST ---
              ...List.generate(widget.quiz.questions.length, (index) {
                final q = widget.quiz.questions[index];
                final answer = widget.studentAnswers[index] ?? '';
                final isCorrect = answer.toLowerCase().trim() == q.correctAnswer.toLowerCase().trim();
                
                return Semantics(
                  label: 'Question ${index + 1}: ${q.text}. Your answer: ${answer.isEmpty ? "No answer" : answer}. Status: ${isCorrect ? "Correct" : "Incorrect. Correct answer: ${q.correctAnswer}"}',
                  child: Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      side: BorderSide(
                        color: isCorrect 
                            ? (ext?.quizCorrectColor ?? Colors.green).withValues(alpha: 0.5) 
                            : (ext?.quizIncorrectColor ?? Colors.red).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    color: isCorrect 
                        ? (ext?.quizCorrectColor ?? Colors.green).withValues(alpha: 0.1) 
                        : (ext?.quizIncorrectColor ?? Colors.red).withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.stackLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Status badge and Points
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Accessible Badge (Shape + Icon + Text double encoding)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.stackSm,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isCorrect ? (ext?.quizCorrectColor ?? Colors.green).withValues(alpha: 0.2) : (ext?.quizIncorrectColor ?? Colors.red).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      color: isCorrect ? (ext?.quizCorrectColor ?? Colors.green) : (ext?.quizIncorrectColor ?? Colors.red),
                                      size: 18,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      isCorrect ? 'CORRECT' : 'INCORRECT',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: isCorrect ? (ext?.quizCorrectColor ?? Colors.green) : (ext?.quizIncorrectColor ?? Colors.red),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCorrect ? q.points : 0} / ${q.points} pts',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.stackMd),
                          
                          // Question Number & Text
                          Text(
                            'Question ${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            q.text,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: AppDimensions.stackMd),
                          
                          // Student Answer Box
                          Text(
                            'Your Answer:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.stackMd,
                              vertical: AppDimensions.stackSm,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect 
                                  ? (ext?.quizCorrectColor ?? Colors.green).withValues(alpha: 0.1) 
                                  : (ext?.quizIncorrectColor ?? Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                              border: Border.all(
                                color: isCorrect ? (ext?.quizCorrectColor ?? Colors.green) : (ext?.quizIncorrectColor ?? Colors.red),
                              ),
                            ),
                            child: Text(
                              answer.isEmpty ? "(No Answer Provided)" : answer,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isCorrect ? (ext?.quizCorrectColor ?? Colors.green) : (ext?.quizIncorrectColor ?? Colors.red),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          // Correct Answer Box (if incorrect)
                          if (!isCorrect) ...[
                            SizedBox(height: AppDimensions.stackMd),
                            Text(
                              'Correct Answer:',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.stackMd,
                                vertical: AppDimensions.stackSm,
                              ),
                              decoration: BoxDecoration(
                                color: (ext?.quizCorrectColor ?? Colors.green).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusDefault),
                                border: Border.all(
                                  color: ext?.quizCorrectColor ?? Colors.green,
                                ),
                              ),
                              child: Text(
                                q.correctAnswer,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: ext?.quizCorrectColor ?? Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          
                          // Explanation Container
                          if (q.explanation != null && q.explanation!.isNotEmpty) ...[
                            SizedBox(height: AppDimensions.stackMd),
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.stackMd),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lightbulb_rounded,
                                    size: 22,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: AppDimensions.stackSm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Explanation',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          q.explanation!,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: AppDimensions.stackLg),
              
              // --- VIEW ACHIEVEMENTS BUTTON ---
              TextButton.icon(
                onPressed: () => context.push('/achievements'),
                icon: const Text('⭐', style: TextStyle(fontSize: 16)),
                label: const Text('View My Achievements'),
              ),
              SizedBox(height: AppDimensions.stackMd),

              // --- RETURN BUTTON ---
              ElevatedButton(
                onPressed: () {
                  context.go('/courses/${widget.courseId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(AppDimensions.touchTargetMin),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Return to Course',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.stackLg),
            ],
          ),
        ),
      ),
    );
  }
}
