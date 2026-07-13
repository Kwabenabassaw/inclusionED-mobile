import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';
class LearningFlowSummary extends ConsumerWidget {
  final Module module;

  const LearningFlowSummary({super.key, required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VisibilityDetector(
      key: Key('summary_${module.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text = 'Lesson Summary. Before taking the quiz, make sure you remember these key points: This module covered the foundational concepts of ${module.title}. You explored the theoretical background and its practical applications. The key takeaways include understanding the primary mechanisms and their impact on the broader system.';
          if (ref.read(currentReadableTextProvider) != text) {
            Future.microtask(() => ref.read(currentReadableTextProvider.notifier).state = text);
          }
        }
      },
      child: ReadingModeWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.stackLg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 32),
                const SizedBox(width: AppDimensions.stackLg),
                Expanded(
                  child: Text(
                    'Lesson Summary',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.stackXl),
          Text(
            'Before taking the quiz, make sure you remember these key points:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppDimensions.stackXl),
          
          // AI Generated Summary (Mocked for now)
          _buildSummaryPoint(context, 'This module covered the foundational concepts of ${module.title}.'),
          _buildSummaryPoint(context, 'You explored the theoretical background and its practical applications.'),
          _buildSummaryPoint(context, 'The key takeaways include understanding the primary mechanisms and their impact on the broader system.'),
        ],
      ),
    )));
  }

  Widget _buildSummaryPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackMd),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(Icons.circle, size: 12, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: AppDimensions.stackLg),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
