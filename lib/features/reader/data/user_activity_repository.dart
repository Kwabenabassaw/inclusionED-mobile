import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_activity.dart';
import '../../authentication/data/auth_repository.dart';
import '../../../core/services/offline_sync_service.dart';

final userActivityRepositoryProvider = Provider<UserActivityRepository>((ref) {
  final firestore = FirebaseFirestore.instance;
  final authRepository = ref.watch(authRepositoryProvider);
  final offlineSync = ref.watch(offlineSyncProvider);
  return UserActivityRepository(firestore, authRepository, offlineSync);
});

class UserActivityRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final OfflineSyncService _offlineSync;

  UserActivityRepository(this._firestore, this._authRepository, this._offlineSync);

  String? get _userId => _authRepository.currentUser?.uid;

  // --- Highlights ---
  Stream<List<UserHighlight>> watchHighlights(String lessonId) {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('user_activity')
        .doc(_userId)
        .collection('highlights')
        .where('lessonId', isEqualTo: lessonId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserHighlight.fromJson(doc.data())).toList();
    });
  }

  Future<void> saveHighlight(UserHighlight highlight) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('highlights')
          .doc(highlight.id)
          .set(highlight.toJson());
    } catch (e) {
      debugPrint("Error saving highlight, queuing offline: $e");
      final payload = highlight.toJson();
      payload['userId'] = _userId;
      payload['type'] = 'highlights';
      _offlineSync.queueUserActivity(payload);
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('highlights')
          .doc(highlightId)
          .delete();
    } catch (e) {
      debugPrint("Offline delete not supported yet. Error: $e");
    }
  }

  // --- Notes ---
  Stream<List<UserNote>> watchNotes(String lessonId) {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('user_activity')
        .doc(_userId)
        .collection('notes')
        .where('lessonId', isEqualTo: lessonId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserNote.fromJson(doc.data())).toList();
    });
  }

  Future<void> saveNote(UserNote note) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('notes')
          .doc(note.id)
          .set(note.toJson());
    } catch (e) {
      debugPrint("Error saving note, queuing offline: $e");
      final payload = note.toJson();
      payload['userId'] = _userId;
      payload['type'] = 'notes';
      _offlineSync.queueUserActivity(payload);
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      debugPrint("Offline delete not supported yet. Error: $e");
    }
  }

  // --- Flashcards ---
  Stream<List<UserFlashcard>> watchFlashcards(String courseId) {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('user_activity')
        .doc(_userId)
        .collection('flashcards')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserFlashcard.fromJson(doc.data())).toList();
    });
  }

  Future<void> saveFlashcard(UserFlashcard flashcard) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('flashcards')
          .doc(flashcard.id)
          .set(flashcard.toJson());
    } catch (e) {
      debugPrint("Error saving flashcard, queuing offline: $e");
      final payload = flashcard.toJson();
      payload['userId'] = _userId;
      payload['type'] = 'flashcards';
      _offlineSync.queueUserActivity(payload);
    }
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('user_activity')
          .doc(_userId)
          .collection('flashcards')
          .doc(flashcardId)
          .delete();
    } catch (e) {
      debugPrint("Offline delete not supported yet. Error: $e");
    }
  }
}
