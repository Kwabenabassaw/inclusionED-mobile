// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_gamification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserGamification _$UserGamificationFromJson(
  Map<String, dynamic> json,
) => _UserGamification(
  userId: json['userId'] as String,
  totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
  level: (json['level'] as num?)?.toInt() ?? 1,
  currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
  lastActivityDate: json['lastActivityDate'] as String?,
  earnedBadgeIds:
      (json['earnedBadgeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  totalNotesAdded: (json['totalNotesAdded'] as num?)?.toInt() ?? 0,
  totalHighlightsAdded: (json['totalHighlightsAdded'] as num?)?.toInt() ?? 0,
  totalLessonsCompleted: (json['totalLessonsCompleted'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserGamificationToJson(_UserGamification instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'totalXp': instance.totalXp,
      'level': instance.level,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastActivityDate': instance.lastActivityDate,
      'earnedBadgeIds': instance.earnedBadgeIds,
      'totalNotesAdded': instance.totalNotesAdded,
      'totalHighlightsAdded': instance.totalHighlightsAdded,
      'totalLessonsCompleted': instance.totalLessonsCompleted,
    };
