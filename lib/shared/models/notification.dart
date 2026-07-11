import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String recipientId,
    required String title,
    required String body,
    required String type, // "ANNOUNCEMENT" | "GRADE" | "ENROLLMENT" | "SYSTEM"
    required String referenceId,
    required bool read,
    required String createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
}
