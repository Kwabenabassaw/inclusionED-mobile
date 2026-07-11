import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_ed_student/shared/models/course.dart';
import 'package:inclusive_ed_student/shared/models/enrollment.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(FirebaseFirestore.instance);
});

class CourseRepository {
  final FirebaseFirestore _firestore;

  CourseRepository(this._firestore);

  // Discover Courses Query (from documentation Phase 5)
  Future<List<Course>> fetchPublishedCourses() async {
    final snapshot = await _firestore
        .collection('courses')
        .where('published', isEqualTo: true)
        .where('archived', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Safely ensure the id from document is present, in case missing in data
      if (!data.containsKey('id') || data['id'] == null) {
        data['id'] = doc.id;
      }
      return Course.fromJson(data);
    }).toList();
  }

  // Student Courses Query by Status
  Future<List<Course>> fetchEnrolledCoursesByStatus(String studentId, String status) async {
    // Step 1: Fetch student enrollments matching status
    final enrollmentSnapshot = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .where('status', isEqualTo: status)
        .get();

    final enrolledCourseIds = enrollmentSnapshot.docs.map((doc) => doc.data()['courseId'] as String).toList();

    if (enrolledCourseIds.isEmpty) return [];

    // Step 2: Fetch courses (using chunks of 10 for "whereIn")
    List<Course> courses = [];
    for (var i = 0; i < enrolledCourseIds.length; i += 10) {
      final chunk = enrolledCourseIds.sublist(i, i + 10 > enrolledCourseIds.length ? enrolledCourseIds.length : i + 10);
      final coursesSnapshot = await _firestore
          .collection('courses')
          .where('id', whereIn: chunk)
          .get();
      
      courses.addAll(coursesSnapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null) {
          data['id'] = doc.id;
        }
        return Course.fromJson(data);
      }));
    }

    return courses;
  }

  // Fetch Course By ID
  Future<Course?> fetchCourseById(String courseId) async {
    final doc = await _firestore.collection('courses').doc(courseId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    if (!data.containsKey('id') || data['id'] == null) {
      data['id'] = doc.id;
    }
    return Course.fromJson(data);
  }

  // Fetch All Enrolled Course IDs (Active, Pending, Completed)
  Future<List<String>> fetchAllEnrolledCourseIds(String studentId) async {
    final enrollmentSnapshot = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: studentId)
        .get();
    return enrollmentSnapshot.docs.map((doc) => doc.data()['courseId'] as String).toList();
  }

  // Request Enrollment
  Future<void> requestEnrollment(String studentId, String courseId) async {
    final docRef = _firestore.collection('enrollments').doc();
    final enrollment = Enrollment(
      id: docRef.id,
      studentId: studentId,
      courseId: courseId,
      status: EnrollmentStatus.pending,
      enrolledAt: DateTime.now().toIso8601String(),
    );
    await docRef.set(enrollment.toJson());
  }

  // Update Enrollment Progress
  Future<void> updateEnrollmentProgress(String enrollmentId, EnrollmentProgress progress) async {
    await _firestore.collection('enrollments').doc(enrollmentId).update({
      'progress': progress.toJson(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Send Learning Event to Progress Engine (Supabase Edge Function)
  Future<void> logLearningEvent({
    required String courseId,
    required String itemId,
    required String type,
    required String status,
    int? timeSpentSeconds,
    int? readingPercentage,
  }) async {
    // We assume the caller gets the enrollment ID via standard flow, 
    // or we fetch it if missing. To keep it simple, we fetch the active enrollment.
    final user = await _firestore.collection('enrollments').where('courseId', isEqualTo: courseId).where('status', isEqualTo: 'ACTIVE').get();
    if (user.docs.isEmpty) return;
    final enrollmentId = user.docs.first.id;

    try {
      final url = Uri.parse("https://qczgiqusaftwmdtkvctn.supabase.co/functions/v1/progress-engine");
      final body = {
        'enrollmentId': enrollmentId,
        'courseId': courseId,
        'itemId': itemId,
        'type': type,
        'status': status,
        if (timeSpentSeconds != null) 'timeSpentSeconds': timeSpentSeconds,
        if (readingPercentage != null) 'readingPercentage': readingPercentage,
      };

      // Implementation using http package (imported at top)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print("Failed to log learning event: \${response.body}");
      }
    } catch (e) {
      print("Error logging learning event: $e");
      // Fallback: Queue offline (to be implemented in Hive/SQLite)
    }
  }

  // Submit Quiz
  Future<void> submitQuiz(Map<String, dynamic> submissionData) async {
    final docRef = _firestore.collection('quizSubmissions').doc();
    submissionData['id'] = docRef.id;
    await docRef.set(submissionData);
  }
}

// Providers for UI
final activeEnrollmentStreamProvider = StreamProvider.family<Enrollment?, String>((ref, courseId) {
  final user = ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return Stream.value(null);

  final query = FirebaseFirestore.instance
      .collection('enrollments')
      .where('studentId', isEqualTo: user.uid)
      .where('status', isEqualTo: 'ACTIVE')
      .where('courseId', isEqualTo: courseId);

  return query.snapshots().map((snapshot) {
    if (snapshot.docs.isEmpty) return null;
    final docs = snapshot.docs;
    final data = docs.first.data();
    data['id'] = docs.first.id;
    return Enrollment.fromJson(data);
  });
});

final availableCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final auth = ref.watch(authRepositoryProvider);
  final user = auth.currentUser;
  
  final allCourses = await repository.fetchPublishedCourses();
  
  if (user == null) return allCourses;
  
  final enrolledCourseIds = await repository.fetchAllEnrolledCourseIds(user.uid);
  return allCourses.where((c) => !enrolledCourseIds.contains(c.id)).toList();
});

final activeCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return repository.fetchEnrolledCoursesByStatus(user.uid, 'ACTIVE');
});

final pendingCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return repository.fetchEnrolledCoursesByStatus(user.uid, 'PENDING');
});

final completedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final user = ref.watch(authRepositoryProvider).currentUser;
  if (user == null) return [];
  return repository.fetchEnrolledCoursesByStatus(user.uid, 'COMPLETED');
});

final courseProvider = FutureProvider.family<Course?, String>((ref, courseId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.fetchCourseById(courseId);
});
