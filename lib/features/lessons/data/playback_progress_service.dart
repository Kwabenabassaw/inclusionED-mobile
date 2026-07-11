import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final playbackProgressServiceProvider = Provider<PlaybackProgressService>((ref) {
  return PlaybackProgressService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

class PlaybackProgressService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PlaybackProgressService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  Future<void> saveProgress({
    required String lessonId,
    required double lastPositionSeconds,
    required double durationSeconds,
    required bool completed,
    required double playbackSpeed,
    required String voice,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore.collection('users').doc(user.uid).collection('ttsProgress').doc(lessonId);

    await docRef.set({
      'lessonId': lessonId,
      'studentId': user.uid,
      'lastPosition': lastPositionSeconds,
      'duration': durationSeconds,
      'completed': completed,
      'lastPlayedAt': FieldValue.serverTimestamp(),
      'playbackSpeed': playbackSpeed,
      'voice': voice,
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getProgress(String lessonId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docRef = _firestore.collection('users').doc(user.uid).collection('ttsProgress').doc(lessonId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }
}
