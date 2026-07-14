import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';
class LearningFlowOverview extends ConsumerWidget {
  final Module module;

  const LearningFlowOverview({super.key, required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VisibilityDetector(
      key: Key('overview_${module.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text = 'Week Overview. ${module.title}. ${module.description}. Learning Objectives: Understand the core concepts of this week. Apply the theoretical knowledge to practical exercises. Complete the final assessment to verify your understanding.';
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
          Text(
            'Week Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.stackLg),
          Text(
            module.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.stackMd),
          Text(
            module.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: AppDimensions.stackXl * 2),
          Text(
            'Learning Objectives',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.stackMd),
          // Mock objectives since they aren't strictly defined in the schema
          _buildObjectiveItem(context, 'Understand the core concepts of this week.'),
          _buildObjectiveItem(context, 'Apply the theoretical knowledge to practical exercises.'),
          _buildObjectiveItem(context, 'Complete the final assessment to verify your understanding.'),
        ],
      ),
    )));
  }

  Widget _buildObjectiveItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackSm),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              excludeSemantics: true,
              child: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            SizedBox(width: AppDimensions.stackSm),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
