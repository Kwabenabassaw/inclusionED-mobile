import 'package:flutter/material.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';

class CourseNavigationChips extends StatelessWidget {
  final String selectedSection;
  final ValueChanged<String> onSectionSelected;

  const CourseNavigationChips({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  static const _sections = [
    'Overview',
    'Learning Journey',
    'Quizzes',
    'Resources',
    'Discussion',
    'Announcements',
    'Grades',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Row(
        children: _sections.map((section) {
          final isSelected = section == selectedSection;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.stackSm),
            child: ChoiceChip(
              label: Text(section),
              selected: isSelected,
              onSelected: (_) => onSectionSelected(section),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
