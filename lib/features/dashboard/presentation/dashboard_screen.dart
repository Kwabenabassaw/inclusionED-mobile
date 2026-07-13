import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/welcome_header.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/schedule_overview.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/active_learning_card.dart';
import 'package:opencampus_lms/features/dashboard/presentation/components/current_courses_list.dart';

import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
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
    );
  }
}
