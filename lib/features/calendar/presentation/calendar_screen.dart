import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';
import 'package:opencampus_lms/shared/models/calendar_event.dart';
import 'package:opencampus_lms/core/widgets/glass_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
  }

  String _formatTimeRange(String startStr, String endStr) {
    try {
      final start = DateTime.parse(startStr);
      final end = DateTime.parse(endStr);
      return '${_formatTime(start)} - ${_formatTime(end)}';
    } catch (_) {
      return 'TBA';
    }
  }

  String _formatTime(DateTime date) {
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final upcomingEventsAsync = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Academic Calendar',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: upcomingEventsAsync.when(
        data: (events) {
          // Group events by day (normalized)
          final Map<DateTime, List<CalendarEvent>> eventsMap = {};
          for (final event in events) {
            try {
              final date = DateTime.parse(event.startDate);
              final normalizedDate = DateTime(date.year, date.month, date.day);
              eventsMap.putIfAbsent(normalizedDate, () => []).add(event);
            } catch (_) {}
          }

          List<CalendarEvent> getEventsForDay(DateTime day) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            return eventsMap[normalizedDay] ?? [];
          }

          final eventsForSelectedDay = getEventsForDay(_selectedDay!);

          return RefreshIndicator(
            onRefresh: () async {
              try {
                // ignore: unused_result
                await ref.refresh(upcomingEventsProvider.future);
              } catch (_) {}
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: GlassCard(
                    margin: const EdgeInsets.all(AppDimensions.marginPage),
                    padding: const EdgeInsets.all(8.0),
                    borderRadius: AppDimensions.radiusLg,
                    child: TableCalendar<CalendarEvent>(
                      firstDay: DateTime.utc(2025, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (!isSameDay(_selectedDay, selectedDay)) {
                          setState(() {
                            _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      eventLoader: getEventsForDay,
                      calendarStyle: CalendarStyle(
                        markerSize: 6,
                        markersMaxCount: 3,
                        markerDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        todayDecoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        formatButtonDecoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.surfaceContainerHighest, width: 1.5),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        formatButtonPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        formatButtonTextStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        titleCentered: true,
                        titleTextStyle: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage, vertical: 8),
                    child: Text(
                      'Events on this day (${eventsForSelectedDay.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (eventsForSelectedDay.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = eventsForSelectedDay[index];
                          return _buildEventCard(context, event);
                        },
                        childCount: eventsForSelectedDay.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading calendar: $err')),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEvent event) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Customize style based on event type
    Color typeColor;
    IconData typeIcon;
    switch (event.type.toLowerCase()) {
      case 'quiz':
        typeColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        typeIcon = Icons.quiz_outlined;
        break;
      case 'assignment':
        typeColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
        typeIcon = Icons.assignment_outlined;
        break;
      case 'class':
      case 'lecture':
        typeColor = theme.colorScheme.primary;
        typeIcon = Icons.menu_book_outlined;
        break;
      default:
        typeColor = theme.colorScheme.secondary;
        typeIcon = Icons.event_available_outlined;
    }

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
      padding: EdgeInsets.zero,
      borderRadius: AppDimensions.radiusLg,
      child: Semantics(
        label: '${event.type} event: ${event.title}',
        hint: 'Double tap to open event details',
        button: true,
        child: InkWell(
          onTap: () {
            // Contextual routing:
            if (event.type.toLowerCase() == 'quiz') {
              context.go('/courses/${event.courseId}/quizzes/${event.id}');
            } else if (event.moduleId != null && event.moduleId!.isNotEmpty) {
              context.go('/courses/${event.courseId}/modules/${event.moduleId}');
            } else {
              context.go('/courses/${event.courseId}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.stackLg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppDimensions.stackMd),
                // Title and Timing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            ),
                            child: Text(
                              event.type.toUpperCase(),
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            _formatTimeRange(event.startDate, event.endDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        event.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          event.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 48, color: theme.colorScheme.secondary),
          SizedBox(height: AppDimensions.stackMd),
          Text(
            'All Clear',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            'No academic events scheduled for this day.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
