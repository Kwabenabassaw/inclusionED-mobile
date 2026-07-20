import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfflineSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late Box<String> _coursesBox;
  late Box<String> _enrollmentsBox;
  late Box<String> _pendingEventsBox;
  late Box<String> _pendingQuizzesBox;
  late Box<String> _pendingUserActivityBox;

  OfflineSyncService() {
    _coursesBox = Hive.box<String>('courses_cache');
    _enrollmentsBox = Hive.box<String>('enrollments_cache');
    _pendingEventsBox = Hive.box<String>('pending_learning_events');
    _pendingQuizzesBox = Hive.box<String>('pending_quiz_submissions');
    _pendingUserActivityBox = Hive.box<String>('pending_user_activity');
  }

  // --- Caching Models ---
  
  void cacheCourse(String courseId, Map<String, dynamic> data) {
    _coursesBox.put(courseId, jsonEncode(data));
  }

  Map<String, dynamic>? getCachedCourse(String courseId) {
    final data = _coursesBox.get(courseId);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }
  
  List<Map<String, dynamic>> getAllCachedCourses() {
    return _coursesBox.values.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  void cacheEnrollment(String enrollmentId, Map<String, dynamic> data) {
    _enrollmentsBox.put(enrollmentId, jsonEncode(data));
  }

  List<Map<String, dynamic>> getAllCachedEnrollments() {
    return _enrollmentsBox.values.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  // --- Queuing Offline Actions ---
  
  void queueLearningEvent(Map<String, dynamic> eventData) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingEventsBox.put(id, jsonEncode(eventData));
    debugPrint('Queued learning event offline: $id');
  }
  
  void queueQuizSubmission(Map<String, dynamic> submissionData) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingQuizzesBox.put(id, jsonEncode(submissionData));
    debugPrint('Queued quiz submission offline: $id');
  }

  void queueUserActivity(Map<String, dynamic> activityData) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _pendingUserActivityBox.put(id, jsonEncode(activityData));
    debugPrint('Queued user activity offline: $id');
  }

  // --- Synchronization Logic ---
  
  Future<void> syncPendingData() async {
    // 1. Sync Learning Events
    final eventKeys = _pendingEventsBox.keys.toList();
    for (var key in eventKeys) {
      final eventDataStr = _pendingEventsBox.get(key);
      if (eventDataStr != null) {
        final eventData = jsonDecode(eventDataStr);
        try {
          final response = await Supabase.instance.client.functions.invoke(
            'progress-engine',
            body: eventData,
          );
          if (response.status == 200) {
            await _pendingEventsBox.delete(key);
            debugPrint('Successfully synced learning event: $key');
          }
        } catch (e) {
          debugPrint('Failed to sync learning event: $e');
        }
      }
    }

    // 2. Sync Quiz Submissions
    final quizKeys = _pendingQuizzesBox.keys.toList();
    for (var key in quizKeys) {
      final quizDataStr = _pendingQuizzesBox.get(key);
      if (quizDataStr != null) {
        final quizData = jsonDecode(quizDataStr) as Map<String, dynamic>;
        try {
          final docRef = _firestore.collection('quizSubmissions').doc();
          quizData['id'] = docRef.id;
          await docRef.set(quizData);
          await _pendingQuizzesBox.delete(key);
          debugPrint('Successfully synced quiz submission: $key');
        } catch (e) {
          debugPrint('Failed to sync quiz submission: $e');
        }
      }
    }

    // 3. Sync User Activity
    final activityKeys = _pendingUserActivityBox.keys.toList();
    for (var key in activityKeys) {
      final activityDataStr = _pendingUserActivityBox.get(key);
      if (activityDataStr != null) {
        final activityData = jsonDecode(activityDataStr) as Map<String, dynamic>;
        try {
          // The structure of queued user activity determines where it goes.
          final String userId = activityData['userId'];
          final String type = activityData['type']; // 'highlights', 'notes', 'flashcards'
          final String docId = activityData['id'];
          
          // Remove the metadata before saving to firestore
          activityData.remove('userId');
          activityData.remove('type');

          await _firestore
              .collection('user_activity')
              .doc(userId)
              .collection(type)
              .doc(docId)
              .set(activityData);

          await _pendingUserActivityBox.delete(key);
          debugPrint('Successfully synced user activity: $key');
        } catch (e) {
          debugPrint('Failed to sync user activity: $e');
        }
      }
    }
  }
}

final offlineSyncProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService();
});
