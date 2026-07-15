import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/shared/models/course.dart';
import 'package:opencampus_lms/shared/models/module.dart';

import 'components/course_banner.dart';
import 'components/course_navigation_chips.dart';
import 'components/current_week_card.dart';
import 'components/upcoming_items_card.dart';
import 'components/course_modules_tab.dart';
import 'components/course_tasks_tab.dart';
import 'components/course_resources_tab.dart';
import 'components/course_announcements_tab.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  String _selectedSection = 'Overview';

  double _calculateProgress(dynamic enrollment, List<Module> modules) {
    if (enrollment == null) return 0.0;
    if (enrollment.progressSummary != null && enrollment.progressSummary.overall != null) {
      return enrollment.progressSummary.overall.percentage / 100.0;
    }
    // Fallback if not yet synced by backend engine
    if (enrollment.progress == null || modules.isEmpty) return 0.0;
    final completedModules = enrollment.progress.completedModuleIds ?? [];
    
    int completedCount = 0;
    for (final module in modules) {
      if (completedModules.contains(module.id)) {
        completedCount++;
      }
    }
    return completedCount / modules.length;
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourse = ref.watch(courseProvider(widget.courseId));
    final enrollmentStream = ref.watch(activeEnrollmentStreamProvider(widget.courseId));
    final asyncModules = ref.watch(courseModulesProvider(widget.courseId));
    final theme = Theme.of(context);

    return asyncCourse.when(
      data: (courseData) {
        final course = courseData;
        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Course Details')),
            body: Center(child: Text('Course not found.')),
          );
        }

        final enrollment = enrollmentStream.value;
        final modules = asyncModules.value ?? <Module>[];
        final progressPercent = _calculateProgress(enrollment, modules);
        
        // Find the first module that is not fully completed to act as "Current"
        final completedModuleIds = enrollment?.progress?.completedModuleIds ?? [];
        final currentModule = modules.isNotEmpty 
            ? modules.firstWhere((m) => !completedModuleIds.contains(m.id), orElse: () => modules.first)
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(course.code, style: const TextStyle(fontWeight: FontWeight.bold)),
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.smart_toy),
                tooltip: 'Course AI Assistant',
                onPressed: () {
                  context.push('/assistant?courseId=${widget.courseId}');
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Invalidate stream providers
              ref.invalidate(activeEnrollmentStreamProvider(widget.courseId));
              // We could also invalidate child tab providers here if imported, but usually 
              // Riverpod's auto-dispose handles those when they're unused, and 
              // refreshing the main course/modules is the primary goal.

              try {
                await Future.wait([
                  ref.refresh(courseProvider(widget.courseId).future),
                  ref.refresh(courseModulesProvider(widget.courseId).future),
                ]);
              } catch (_) {}
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseBanner(
                    course: course,
                    progressPercent: progressPercent,
                    currentModuleId: currentModule?.id,
                  ),
                  SizedBox(height: AppDimensions.stackLg),
                  CourseNavigationChips(
                    selectedSection: _selectedSection,
                    onSectionSelected: (section) {
                      setState(() {
                        _selectedSection = section;
                      });
                    },
                  ),
                  SizedBox(height: AppDimensions.stackXl),
                  
                  // Render content based on selected section
                  _buildSectionContent(course, currentModule, enrollment),
                  
                  SizedBox(height: AppDimensions.stackXl * 2),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text('Loading...')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionContent(Course course, Module? currentModule, dynamic enrollment) {
    switch (_selectedSection) {
      case 'Overview':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentWeekCard(
              activeModule: currentModule,
              onContinue: () {
                setState(() {
                  _selectedSection = 'Learning Journey';
                });
              },
            ),
            SizedBox(height: AppDimensions.stackXl),
            UpcomingItemsCard(
              courseId: course.id,
              moduleId: currentModule?.id,
              completedQuizIds: enrollment?.progress?.completedQuizIds ?? [],
            ),
            SizedBox(height: AppDimensions.stackXl),
          ],
        );
      case 'Learning Journey':
        return CourseModulesTab(courseId: course.id);
      case 'Quizzes':
        return CourseTasksTab(courseId: course.id, moduleId: currentModule?.id);
      case 'Resources':
        return CourseResourcesTab(courseId: course.id);
      case 'Announcements':
        return CourseAnnouncementsTab(courseId: course.id);
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            child: Text('$_selectedSection coming soon...'),
          ),
        );
    }
  }
}

