import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/welcome_header.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/schedule_overview.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/active_learning_card.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/current_courses_list.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await Future.wait([
                ref.refresh(activeCoursesProvider.future),
                ref.refresh(upcomingEventsProvider.future),
              ]);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                WelcomeHeader(),
                SizedBox(height: AppDimensions.stackXl),

                ScheduleOverview(),
                SizedBox(height: AppDimensions.stackXl),

                ActiveLearningCard(),
                SizedBox(height: AppDimensions.stackXl),

                CurrentCoursesList(),
                SizedBox(height: 80), // Padding for the FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}
