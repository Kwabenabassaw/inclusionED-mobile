import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/shared/models/assignment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

final assignmentRepositoryProvider = Provider<AssignmentRepository>((ref) {
  return AssignmentRepository(
    FirebaseFirestore.instance,
    Supabase.instance.client,
  );
});

// A stream provider for fetching assignments for a specific course
final courseAssignmentsProvider = StreamProvider.family<List<Assignment>, String>((ref, courseId) {
  final repository = ref.watch(assignmentRepositoryProvider);
  return repository.watchCourseAssignments(courseId);
});

// A future provider to fetch a student's submission for an assignment
final assignmentSubmissionProvider = FutureProvider.family<AssignmentSubmission?, ({String assignmentId, String studentId})>((ref, args) {
  final repository = ref.watch(assignmentRepositoryProvider);
  return repository.getStudentSubmission(args.assignmentId, args.studentId);
});

class AssignmentRepository {
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  AssignmentRepository(this._firestore, this._supabase);

  Stream<List<Assignment>> watchCourseAssignments(String courseId) {
    return _firestore
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Assignment.fromJson({...doc.data(), 'id': doc.id})).toList();
    });
  }

  Future<AssignmentSubmission?> getStudentSubmission(String assignmentId, String studentId) async {
    final query = await _firestore
        .collection('assignmentSubmissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return AssignmentSubmission.fromJson({...query.docs.first.data(), 'id': query.docs.first.id});
  }

  Future<AssignmentSubmission> submitAssignment({
    required String assignmentId,
    required String studentId,
    required File file,
  }) async {
    // 1. Upload to Supabase Storage
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final filePath = 'submissions/$assignmentId/$studentId/$fileName';

    await _supabase.storage.from('course-assets').upload(
      filePath,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    // 2. Get public URL
    final publicUrl = _supabase.storage.from('course-assets').getPublicUrl(filePath);

    // 3. Save to Firestore
    final docRef = _firestore.collection('assignmentSubmissions').doc();
    final submission = AssignmentSubmission(
      id: docRef.id,
      assignmentId: assignmentId,
      studentId: studentId,
      status: 'SUBMITTED',
      submittedFileUrl: publicUrl,
      submittedFileName: fileName,
      submittedAt: DateTime.now().toIso8601String(),
    );

    await docRef.set(submission.toJson());
    return submission;
  }
}
