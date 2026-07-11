import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum UserRole {
  @JsonValue('ADMIN') admin,
  @JsonValue('INSTRUCTOR') instructor,
  @JsonValue('STUDENT') student,
}

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String id,
    required String displayName,
    required String email,
    @Default(UserRole.student) UserRole role,
    @Default('General') String department,
    String? faculty,
    String? academicLevel,
    String? studentId,
    required String avatar,
    String? bio,
    required String joinedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}
