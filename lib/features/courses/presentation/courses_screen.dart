import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';
import 'package:inclusive_ed_student/features/courses/data/course_repository.dart';
import 'package:inclusive_ed_student/shared/models/course.dart';

final courseStatusFilterProvider = StateProvider<String>((ref) => 'ACTIVE');
final catalogSearchQueryProvider = StateProvider<String>((ref) => '');

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'LMS Curriculum',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  labelColor: theme.colorScheme.onPrimaryContainer,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                  tabs: const [
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('My Courses'),
                      ),
                    ),
                    Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Find Catalog'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            _MyCoursesTab(),
            _CatalogTab(),
          ],
        ),
      ),
    );
  }
}

class _MyCoursesTab extends ConsumerWidget {
  const _MyCoursesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(courseStatusFilterProvider);
    
    final asyncCourses = switch (statusFilter) {
      'PENDING' => ref.watch(pendingCoursesProvider),
      'COMPLETED' => ref.watch(completedCoursesProvider),
      _ => ref.watch(activeCoursesProvider),
    };

    return Column(
      children: [
        // Custom Chip Selector for Status
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Row(
            children: [
              _buildFilterChip(context, ref, 'ACTIVE', 'Active Studies', Icons.auto_stories),
              const SizedBox(width: AppDimensions.stackMd),
              _buildFilterChip(context, ref, 'PENDING', 'Pending Request', Icons.hourglass_empty),
              const SizedBox(width: AppDimensions.stackMd),
              _buildFilterChip(context, ref, 'COMPLETED', 'Completed', Icons.task_alt),
            ],
          ),
        ),
        Expanded(
          child: asyncCourses.when(
            data: (courses) {
              if (courses.isEmpty) {
                return _buildEmptyState(context, statusFilter);
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _CourseCard(course: courses[index], isEnrolled: true);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, 
    WidgetRef ref, 
    String value, 
    String label, 
    IconData icon
  ) {
    final activeValue = ref.watch(courseStatusFilterProvider);
    final isSelected = activeValue == value;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => ref.read(courseStatusFilterProvider.notifier).state = value,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    final theme = Theme.of(context);
    final String title = switch (filter) {
      'PENDING' => 'No Pending Requests',
      'COMPLETED' => 'No Completed Courses Yet',
      _ => 'No Enrolled Courses',
    };
    final String description = switch (filter) {
      'PENDING' => 'Your requests are awaiting approval from instructors.',
      'COMPLETED' => 'Your achievements will be archived here upon completion.',
      _ => 'Enroll in accessible curriculum modules to launch your studies.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(height: AppDimensions.stackMd),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.stackSm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogTab extends ConsumerWidget {
  const _CatalogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCourses = ref.watch(availableCoursesProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: TextField(
            onChanged: (value) => ref.read(catalogSearchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search course code or title...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: asyncCourses.when(
            data: (courses) {
              final filtered = courses.where((c) {
                final matchName = c.name.toLowerCase().contains(searchQuery.toLowerCase());
                final matchCode = c.code.toLowerCase().contains(searchQuery.toLowerCase());
                return matchName || matchCode;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.marginPage),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: theme.colorScheme.secondary),
                        const SizedBox(height: AppDimensions.stackMd),
                        const Text(
                          'No courses match your search',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return _CourseCard(course: filtered[index], isEnrolled: false);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends ConsumerStatefulWidget {
  final Course course;
  final bool isEnrolled;

  const _CourseCard({required this.course, required this.isEnrolled});

  @override
  ConsumerState<_CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<_CourseCard> {
  bool _enrolling = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = widget.course;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppDimensions.stackLg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: () => context.go('/courses/${course.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // B2 Cover Banner / Placeholder
              SizedBox(
                height: 140,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                          ? Image.network(
                              course.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholderCover(context),
                            )
                          : _buildPlaceholderCover(context),
                    ),
                    // High-contrast accessibility score badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.accessibility_new,
                              size: 14,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.accessibilityScore}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Level badge on bottom-left
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          course.level.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.stackLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          course.code,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          course.term,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.stackSm),
                    Text(
                      course.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.stackLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.apartment, size: 16, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              course.department,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (!widget.isEnrolled)
                          ElevatedButton(
                            onPressed: _enrolling ? null : () => _enrollStudent(ref),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(100, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                              ),
                            ),
                            child: _enrolling
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Enroll'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.2),
            theme.colorScheme.secondary.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.book,
          size: 40,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Future<void> _enrollStudent(WidgetRef ref) async {
    final auth = ref.read(authRepositoryProvider);
    final user = auth.currentUser;
    if (user == null) return;

    setState(() {
      _enrolling = true;
    });

    try {
      await ref.read(courseRepositoryProvider).requestEnrollment(user.uid, widget.course.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrollment request submitted for ${widget.course.name}.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      ref.invalidate(availableCoursesProvider);
      ref.invalidate(pendingCoursesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit enrollment request: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enrolling = false;
        });
      }
    }
  }
}
