import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/shared/models/user_gamification.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  return GamificationRepository(FirebaseFirestore.instance, auth);
});

final gamificationStreamProvider = StreamProvider<UserGamification?>((ref) {
  return ref.watch(gamificationRepositoryProvider).watchGamification();
});

// ── Repository ─────────────────────────────────────────────────────────────

class GamificationRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _auth;

  GamificationRepository(this._firestore, this._auth);

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('gamification').doc('stats');
  }

  Stream<UserGamification?> watchGamification() {
    final doc = _doc;
    if (doc == null) return Stream.value(null);
    return doc.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserGamification.fromJson(snap.data()!);
    });
  }

  Future<UserGamification?> fetch() async {
    final doc = _doc;
    if (doc == null) return null;
    final snap = await doc.get();
    if (!snap.exists || snap.data() == null) return null;
    return UserGamification.fromJson(snap.data()!);
  }

  Future<void> save(UserGamification stats) async {
    final doc = _doc;
    if (doc == null) return;
    await doc.set(stats.toJson(), SetOptions(merge: true));
  }

  /// Core XP award method. Returns the updated stats + whether a level-up occurred.
  Future<({UserGamification stats, bool leveledUp, List<BadgeId> newBadges})>
      awardXp(int xp, {
    bool lessonCompleted   = false,
    bool noteAdded         = false,
    bool highlightAdded    = false,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final existing = await fetch() ??
        UserGamification(userId: uid);

    final oldLevel = existing.level;
    final newXp    = existing.totalXp + xp;
    final newLevel = levelFromXp(newXp);

    // ── Streak calculation ──────────────────────────────────────────────────
    final today = _todayString();
    final yesterday = _yesterdayString();
    final lastDate = existing.lastActivityDate;

    int newStreak = existing.currentStreak;
    if (lastDate == today) {
      // Already logged today, no streak change
    } else if (lastDate == yesterday) {
      // Consecutive day
      newStreak = existing.currentStreak + 1;
    } else {
      // Streak broken
      newStreak = 1;
    }
    final newLongest = newStreak > existing.longestStreak
        ? newStreak
        : existing.longestStreak;

    // ── Counters ────────────────────────────────────────────────────────────
    final newNotesTotal      = existing.totalNotesAdded      + (noteAdded      ? 1 : 0);
    final newHighlightsTotal = existing.totalHighlightsAdded + (highlightAdded ? 1 : 0);
    final newLessonsTotal    = existing.totalLessonsCompleted + (lessonCompleted ? 1 : 0);

    // ── Badge evaluation ────────────────────────────────────────────────────
    final earnedSet = Set<String>.from(existing.earnedBadgeIds);
    final newBadges = <BadgeId>[];

    void checkBadge(BadgeId badge, bool condition) {
      final id = badge.name;
      if (condition && !earnedSet.contains(id)) {
        earnedSet.add(id);
        newBadges.add(badge);
      }
    }

    checkBadge(BadgeId.firstLesson,  newLessonsTotal >= 1);
    checkBadge(BadgeId.noteTaker,    newNotesTotal >= 10);
    checkBadge(BadgeId.highlighter,  newHighlightsTotal >= 20);
    checkBadge(BadgeId.streak3,      newStreak >= 3);
    checkBadge(BadgeId.streak7,      newStreak >= 7);
    checkBadge(BadgeId.streak30,     newStreak >= 30);
    checkBadge(BadgeId.level5,       newLevel >= 5);
    checkBadge(BadgeId.level10,      newLevel >= 10);

    final updated = UserGamification(
      userId:                 uid,
      totalXp:               newXp,
      level:                 newLevel,
      currentStreak:         newStreak,
      longestStreak:         newLongest,
      lastActivityDate:      today,
      earnedBadgeIds:        earnedSet.toList(),
      totalNotesAdded:       newNotesTotal,
      totalHighlightsAdded:  newHighlightsTotal,
      totalLessonsCompleted: newLessonsTotal,
    );

    try {
      await save(updated);
    } catch (e) {
      debugPrint('GamificationRepository: Error saving stats: $e');
    }

    return (
      stats:    updated,
      leveledUp: newLevel > oldLevel,
      newBadges: newBadges,
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}
