import 'package:flutter/material.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/shared/models/module.dart';

class LearningFlowSummary extends StatelessWidget {
  final Module module;

  const LearningFlowSummary({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildSummaryPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(Icons.circle, size: 12, color: Theme.of(context).colorScheme.primary),
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
    );
  }
}
