import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/features/gamification/presentation/xp_celebration_overlay.dart';
import 'package:opencampus_lms/features/gamification/presentation/achievements_screen.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

class LearningFlowCompletion extends ConsumerStatefulWidget {
  final Module module;
  final VoidCallback onComplete;

  const LearningFlowCompletion({
    super.key,
    required this.module,
    required this.onComplete,
  });

  @override
  ConsumerState<LearningFlowCompletion> createState() => _LearningFlowCompletionState();
}

class _LearningFlowCompletionState extends ConsumerState<LearningFlowCompletion> {
  bool _xpAwarded = false;

  Future<void> _awardCompletionXp() async {
    if (_xpAwarded) return;
    _xpAwarded = true;

    try {
      final result = await ref.read(gamificationRepositoryProvider).awardXp(
        XpEvent.completedLesson,
        lessonCompleted: true,
      );

      if (!mounted) return;

      if (result.leveledUp || result.newBadges.isNotEmpty) {
        await XpCelebrationOverlay.show(
          context,
          newLevel: result.stats.level,
          xpAwarded: XpEvent.completedLesson,
          newBadges: result.newBadges,
        );
      } else {
        // Minor toast for XP without level-up
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: XpToast(xp: XpEvent.completedLesson, label: 'Lesson complete!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Gamification failure should never block lesson completion
      debugPrint('Gamification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('completion_${widget.module.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text = 'Week Completed! Congratulations on finishing ${widget.module.title}.';
          if (ref.read(currentReadableTextProvider) != text) {
            Future.microtask(() => ref.read(currentReadableTextProvider.notifier).state = text);
          }
          // Award XP when this page becomes fully visible
          Future.microtask(() => _awardCompletionXp());
        }
      },
      child: ReadingModeWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.stars,
                  size: 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: AppDimensions.stackXl),
                Text(
                  'Week Completed!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.stackLg),
                Text(
                  'Congratulations on finishing ${widget.module.title}.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.stackLg),
                // XP earned indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.shade600, width: 1.5),
                  ),
                  child: Text(
                    '+${XpEvent.completedLesson} XP Earned',
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.stackMd),
                // View achievements button
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  ),
                  icon: const Text('⭐', style: TextStyle(fontSize: 16)),
                  label: const Text('View Achievements'),
                ),
                SizedBox(height: AppDimensions.stackXl * 2),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: widget.onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: Text('Return to Course Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
