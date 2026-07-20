import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_gamification.freezed.dart';
part 'user_gamification.g.dart';

/// XP thresholds per level. Level = index + 1.
const List<int> kXpThresholds = [
  0,    // Level 1  — 0 XP
  100,  // Level 2  — 100 XP
  250,  // Level 3  — 250 XP
  500,  // Level 4  — 500 XP
  900,  // Level 5  — 900 XP
  1400, // Level 6  — 1400 XP
  2000, // Level 7  — 2000 XP
  2800, // Level 8  — 2800 XP
  3800, // Level 9  — 3800 XP
  5000, // Level 10 — 5000 XP (max displayed)
];

/// XP awarded for each action.
class XpEvent {
  static const int completedLesson    = 50;
  static const int addedNote          = 10;
  static const int addedHighlight     = 5;
  static const int completedQuiz      = 30;
  static const int perfectQuiz        = 20; // Bonus on top of completedQuiz
  static const int dailyLoginStreak   = 15;
  static const int weeklyStreak       = 50;
}

/// Badge definitions.
enum BadgeId {
  firstLesson,    // Completed first lesson
  noteTaker,      // Added 10 notes
  highlighter,    // Added 20 highlights
  streak3,        // 3-day streak
  streak7,        // 7-day streak
  streak30,       // 30-day streak
  level5,         // Reached Level 5
  level10,        // Reached Level 10
  quizAce,        // Scored 100% on a quiz
}

/// Metadata for each badge — what the user sees.
class BadgeDefinition {
  final BadgeId id;
  final String name;
  final String description;
  final String icon; // emoji icon

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

const Map<BadgeId, BadgeDefinition> kBadgeDefinitions = {
  BadgeId.firstLesson:  BadgeDefinition(id: BadgeId.firstLesson,  name: 'First Steps',      description: 'Complete your first lesson.',          icon: '🎯'),
  BadgeId.noteTaker:    BadgeDefinition(id: BadgeId.noteTaker,    name: 'Note Taker',        description: 'Add 10 notes across your lessons.',    icon: '📝'),
  BadgeId.highlighter:  BadgeDefinition(id: BadgeId.highlighter,  name: 'Highlighter',       description: 'Highlight 20 passages.',               icon: '🖊️'),
  BadgeId.streak3:      BadgeDefinition(id: BadgeId.streak3,      name: 'On Fire 🔥',        description: 'Maintain a 3-day streak.',             icon: '🔥'),
  BadgeId.streak7:      BadgeDefinition(id: BadgeId.streak7,      name: 'Week Warrior',      description: 'Maintain a 7-day streak.',             icon: '⚡'),
  BadgeId.streak30:     BadgeDefinition(id: BadgeId.streak30,     name: 'Iron Will',         description: 'Maintain a 30-day streak.',            icon: '💎'),
  BadgeId.level5:       BadgeDefinition(id: BadgeId.level5,       name: 'Rising Star',       description: 'Reach Level 5.',                       icon: '⭐'),
  BadgeId.level10:      BadgeDefinition(id: BadgeId.level10,      name: 'Scholar',           description: 'Reach Level 10.',                      icon: '🎓'),
  BadgeId.quizAce:      BadgeDefinition(id: BadgeId.quizAce,      name: 'Quiz Ace',          description: 'Score 100% on any quiz.',              icon: '🏆'),
};

/// Firestore document stored at `users/{uid}/gamification/stats`
@freezed
abstract class UserGamification with _$UserGamification {
  const factory UserGamification({
    required String userId,
    @Default(0) int totalXp,
    @Default(1) int level,
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    String? lastActivityDate,          // 'yyyy-MM-dd' format
    @Default([]) List<String> earnedBadgeIds,
    @Default(0) int totalNotesAdded,
    @Default(0) int totalHighlightsAdded,
    @Default(0) int totalLessonsCompleted,
  }) = _UserGamification;

  factory UserGamification.fromJson(Map<String, dynamic> json) =>
      _$UserGamificationFromJson(json);
}

/// Helper to determine the current level from total XP.
int levelFromXp(int xp) {
  int level = 1;
  for (int i = 0; i < kXpThresholds.length; i++) {
    if (xp >= kXpThresholds[i]) {
      level = i + 1;
    } else {
      break;
    }
  }
  return level.clamp(1, kXpThresholds.length);
}

/// XP progress within the current level (0.0 – 1.0).
double xpProgress(int xp) {
  final level = levelFromXp(xp);
  if (level >= kXpThresholds.length) return 1.0;
  final levelStart = kXpThresholds[level - 1];
  final levelEnd   = kXpThresholds[level];
  if (levelEnd == levelStart) return 1.0;
  return ((xp - levelStart) / (levelEnd - levelStart)).clamp(0.0, 1.0);
}
