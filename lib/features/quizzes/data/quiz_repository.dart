import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/shared/models/quiz.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(FirebaseFirestore.instance);
});

class QuizRepository {
  final FirebaseFirestore _firestore;

  QuizRepository(this._firestore);

  Future<Quiz?> fetchQuiz(String quizId) async {
    try {
      final doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      data['id'] = doc.id;
      return Quiz.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }
  Future<List<Quiz>> fetchQuizzesForModule(String moduleId) async {
    try {
      final snapshot = await _firestore
          .collection('quizzes')
          .where('moduleId', isEqualTo: moduleId)
          .where('published', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Quiz.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load quizzes for module: $e');
    }
  }
}

final quizProvider = FutureProvider.family<Quiz?, String>((ref, quizId) async {
  return ref.watch(quizRepositoryProvider).fetchQuiz(quizId);
});

final moduleQuizzesProvider = FutureProvider.family<List<Quiz>, String>((ref, moduleId) async {
  return ref.watch(quizRepositoryProvider).fetchQuizzesForModule(moduleId);
});
