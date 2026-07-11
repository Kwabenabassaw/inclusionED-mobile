import 'package:flutter/material.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/shared/models/module.dart';

class LearningFlowOverview extends StatelessWidget {
  final Module module;

  const LearningFlowOverview({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          const SizedBox(height: AppDimensions.stackLg),
          Text(
            module.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          Text(
            module.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppDimensions.stackXl * 2),
          Text(
            'Learning Objectives',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.stackMd),
          // Mock objectives since they aren't strictly defined in the schema
          _buildObjectiveItem(context, 'Understand the core concepts of this week.'),
          _buildObjectiveItem(context, 'Apply the theoretical knowledge to practical exercises.'),
          _buildObjectiveItem(context, 'Complete the final assessment to verify your understanding.'),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.stackSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: AppDimensions.stackSm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
