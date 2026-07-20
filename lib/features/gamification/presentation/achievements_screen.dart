import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/gamification/data/gamification_repository.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

/// Compact XP chip shown in AppBars — displays level + XP progress bar.
class XpHudChip extends ConsumerWidget {
  const XpHudChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gamificationStreamProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) return const SizedBox.shrink();
        final progress = xpProgress(stats.totalXp);
        return Semantics(
          label: 'Level ${stats.level}, ${stats.totalXp} XP',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⭐ Lv.${stats.level}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 48,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Full achievements / profile gamification screen.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gamificationStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('Start learning to earn XP!'));
          }
          return ListView(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            children: [
              _buildXpCard(context, stats),
              const SizedBox(height: AppDimensions.stackXl),
              _buildStreakCard(context, stats),
              const SizedBox(height: AppDimensions.stackXl),
              _buildStatsRow(context, stats),
              const SizedBox(height: AppDimensions.stackXl),
              _buildBadgesGrid(context, stats),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildXpCard(BuildContext context, UserGamification stats) {
    final progress = xpProgress(stats.totalXp);
    final level = stats.level;
    final nextThreshold =
        level < kXpThresholds.length ? kXpThresholds[level] : stats.totalXp;
    final prevThreshold = kXpThresholds[level - 1];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '⭐',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.stackMd),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level $level',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Text(
                    '${stats.totalXp} XP total',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$prevThreshold XP',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                '${stats.totalXp} / $nextThreshold XP',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.stackSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          if (level < kXpThresholds.length) ...[
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              '${nextThreshold - stats.totalXp} XP to Level ${level + 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ] else ...[
            const SizedBox(height: AppDimensions.stackSm),
            const Text(
              'Max Level Reached! 🎓',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, UserGamification stats) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.stackLg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Row(
        children: [
          Text(
            stats.currentStreak > 0 ? '🔥' : '💤',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: AppDimensions.stackMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.currentStreak}-Day Streak',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Best: ${stats.longestStreak} days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, UserGamification stats) {
    return Row(
      children: [
        Expanded(child: _statChip(context, '📚', '${stats.totalLessonsCompleted}', 'Lessons')),
        const SizedBox(width: AppDimensions.stackMd),
        Expanded(child: _statChip(context, '📝', '${stats.totalNotesAdded}', 'Notes')),
        const SizedBox(width: AppDimensions.stackMd),
        Expanded(child: _statChip(context, '🖊️', '${stats.totalHighlightsAdded}', 'Highlights')),
      ],
    );
  }

  Widget _statChip(BuildContext context, String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.stackMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, UserGamification stats) {
    final earned = Set<String>.from(stats.earnedBadgeIds);
    final badges = BadgeId.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges  (${earned.length}/${badges.length})',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDimensions.stackMd),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppDimensions.stackMd,
            crossAxisSpacing: AppDimensions.stackMd,
            childAspectRatio: 0.85,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final def = kBadgeDefinitions[badge]!;
            final isEarned = earned.contains(badge.name);

            return Tooltip(
              message: def.description,
              child: Container(
                decoration: BoxDecoration(
                  color: isEarned
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: isEarned
                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEarned ? def.icon : '🔒',
                      style: TextStyle(
                        fontSize: 32,
                        color: isEarned ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        def.name,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isEarned
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
