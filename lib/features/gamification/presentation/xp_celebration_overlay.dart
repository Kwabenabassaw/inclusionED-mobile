import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

/// Full-screen celebration overlay shown when a user levels up.
/// Wrap over any screen by pushing it with [XpCelebrationOverlay.show].
class XpCelebrationOverlay extends StatefulWidget {
  final int newLevel;
  final int xpAwarded;
  final List<BadgeId> newBadges;
  final VoidCallback onDismiss;

  const XpCelebrationOverlay({
    super.key,
    required this.newLevel,
    required this.xpAwarded,
    required this.newBadges,
    required this.onDismiss,
  });

  /// Convenience method — push this overlay as a dialog over the current route.
  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required int xpAwarded,
    required List<BadgeId> newBadges,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) => XpCelebrationOverlay(
        newLevel: newLevel,
        xpAwarded: xpAwarded,
        newBadges: newBadges,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<XpCelebrationOverlay> createState() => _XpCelebrationOverlayState();
}

class _XpCelebrationOverlayState extends State<XpCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start confetti after a short delay so the entrance animation is visible
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLevelUp = widget.newLevel > 1;

    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Confetti cannon from top ─────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // downward
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 30,
              minBlastForce: 10,
              emissionFrequency: 0.06,
              numberOfParticles: 25,
              gravity: 0.3,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
                Colors.amber,
                Colors.pink,
              ],
            ),
          ),

          // ── Main card ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Level-up star icon with pulse
                if (isLevelUp) ...[
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '⭐',
                          style: TextStyle(fontSize: 56),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                  Text(
                    'LEVEL UP!',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackSm),
                  Text(
                    'Level ${widget.newLevel}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Text(
                    '🎉',
                    style: const TextStyle(fontSize: 72),
                  ),
                  const SizedBox(height: AppDimensions.stackLg),
                ],

                const SizedBox(height: AppDimensions.stackMd),

                // XP awarded chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.stackLg,
                    vertical: AppDimensions.stackSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: Colors.amber, width: 1.5),
                  ),
                  child: Text(
                    '+${widget.xpAwarded} XP',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // New badges section
                if (widget.newBadges.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.stackXl),
                  Text(
                    'New Badge${widget.newBadges.length > 1 ? 's' : ''} Unlocked!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.stackMd),
                  Wrap(
                    spacing: AppDimensions.stackMd,
                    runSpacing: AppDimensions.stackMd,
                    alignment: WrapAlignment.center,
                    children: widget.newBadges.map((badge) {
                      final def = kBadgeDefinitions[badge]!;
                      return _BadgeChip(definition: def);
                    }).toList(),
                  ),
                ],

                const SizedBox(height: AppDimensions.stackXl * 2),

                // Dismiss button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onDismiss,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: Text(
                      'Keep Going! 🚀',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final BadgeDefinition definition;
  const _BadgeChip({required this.definition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(definition.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                definition.description,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A small inline XP toast — shown for minor events like adding a highlight.
class XpToast extends StatelessWidget {
  final int xp;
  final String? label;
  const XpToast({super.key, required this.xp, this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.shade800,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '+$xp XP${label != null ? '  •  $label' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
