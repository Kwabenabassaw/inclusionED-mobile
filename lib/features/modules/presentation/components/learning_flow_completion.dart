import 'package:flutter/material.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/modules/presentation/components/reading_mode_wrapper.dart';

class LearningFlowCompletion extends ConsumerWidget {
  final Module module;
  final VoidCallback onComplete;

  const LearningFlowCompletion({
    super.key,
    required this.module,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VisibilityDetector(
      key: Key('completion_${module.id}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.5) {
          final text = 'Week Completed! Congratulations on finishing ${module.title}.';
          if (ref.read(currentReadableTextProvider) != text) {
            Future.microtask(() => ref.read(currentReadableTextProvider.notifier).state = text);
          }
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
            const SizedBox(height: AppDimensions.stackXl),
            Text(
              'Week Completed!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.stackLg),
            Text(
              'Congratulations on finishing ${module.title}.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.stackXl * 2),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                ),
                child: const Text('Return to Course Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    )));
  }
}
