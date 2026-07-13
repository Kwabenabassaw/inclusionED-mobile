import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';

class AssistantShortcut extends StatelessWidget {
  const AssistantShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: () => context.push('/assistant'),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.stackLg),
          child: Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                size: 32,
              ),
              const SizedBox(width: AppDimensions.stackMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Assistant',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Need help? Ask your personalized assistant.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
