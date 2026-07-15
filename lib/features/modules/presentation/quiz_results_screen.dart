import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/core/theme/app_theme.dart';
import 'package:opencampus_lms/shared/models/quiz.dart';

class QuizResultsScreen extends StatelessWidget {
  final String courseId;
  final Quiz quiz;
  final Map<int, String> studentAnswers;
  
  const QuizResultsScreen({
    super.key,
    required this.courseId,
    required this.quiz,
    required this.studentAnswers,
  });

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      final answer = studentAnswers[i] ?? '';
      if (answer.toLowerCase().trim() == q.correctAnswer.toLowerCase().trim()) {
        score += q.points;
      }
    }
    return score;
  }

  int _calculateCorrectCount() {
    int count = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      final q = quiz.questions[i];
      final answer = studentAnswers[i] ?? '';
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
    final percentage = quiz.totalPoints > 0 ? (score / quiz.totalPoints) * 100 : 0.0;
    final isPassed = percentage >= 60.0; // Standard passing threshold
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Quiz Results'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
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
                label: 'Quiz result summary: You scored $score out of ${quiz.totalPoints} points. Percentage: ${percentage.toStringAsFixed(0)}%. ${isPassed ? "You passed!" : "You can try again."}',
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
                                color: isPassed ? (ext?.quizCorrectColor ?? Colors.green.shade600) : theme.colorScheme.primary,
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
                                  '$score / ${quiz.totalPoints} pts',
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
                          isPassed ? 'Congratulations! You Passed' : 'Keep Learning!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppDimensions.stackSm),
                        Text(
                          'You correctly answered $correctCount out of ${quiz.questions.length} questions.',
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
              
              // --- REVIEW SECTION HEADER ---
              Text(
                'Review Answers',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.stackMd),

              // --- ANSWERS LIST ---
              ...List.generate(quiz.questions.length, (index) {
                final q = quiz.questions[index];
                final answer = studentAnswers[index] ?? '';
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
              
              // --- RETURN BUTTON ---
              ElevatedButton(
                onPressed: () {
                  context.go('/courses/$courseId');
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
