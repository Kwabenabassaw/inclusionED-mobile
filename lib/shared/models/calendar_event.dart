import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_event.freezed.dart';
part 'calendar_event.g.dart';

@freezed
abstract class CalendarEvent with _$CalendarEvent {
  const factory CalendarEvent({
    required String id,
    required String courseId,
    String? moduleId,
    required String title,
    String? description,
    required String type,
    required String startDate,
    required String endDate,
    required bool allDay,
    required bool isPublished,
    required String createdBy,
  }) = _CalendarEvent;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => _$CalendarEventFromJson(json);
}
