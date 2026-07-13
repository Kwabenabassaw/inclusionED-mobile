import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/shared/models/content.dart';

final moduleRepositoryProvider = Provider<ModuleRepository>((ref) {
  return ModuleRepository(FirebaseFirestore.instance);
});

class ModuleRepository {
  final FirebaseFirestore _firestore;

  ModuleRepository(this._firestore);

  Future<List<Module>> fetchCourseModules(String courseId) async {
    final snapshot = await _firestore
        .collection('modules')
        .where('courseId', isEqualTo: courseId)
        .get();

    final docs = snapshot.docs.where((doc) {
      final data = doc.data();
      final isPublished = data['isPublished'] == true;
      final status = data['status'];
      return isPublished && (status == 'READY' || status == 'PUBLISHED');
    }).toList();

    docs.sort((a, b) {
      final aIndex = a.data()['orderIndex'] as int? ?? 0;
      final bIndex = b.data()['orderIndex'] as int? ?? 0;
      return aIndex.compareTo(bIndex);
    });

    return docs.map((doc) {
      final data = doc.data();
      if (!data.containsKey('id') || data['id'] == null) data['id'] = doc.id;
      return Module.fromJson(data);
    }).toList();
  }

  Future<List<Content>> fetchModuleContents(String courseId, String moduleId) async {
    final snapshot = await _firestore
        .collection('contents')
        .where('courseId', isEqualTo: courseId)
        .where('moduleId', isEqualTo: moduleId)
        .where('status', whereIn: ['COMPLETED', 'PUBLISHED'])
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      if (!data.containsKey('id') || data['id'] == null) data['id'] = doc.id;
      return Content.fromJson(data);
    }).toList();
  }
  Future<Module?> fetchModule(String moduleId) async {
    final doc = await _firestore.collection('modules').doc(moduleId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return Module.fromJson(data);
  }
}

final courseModulesProvider = FutureProvider.family<List<Module>, String>((ref, courseId) async {
  return ref.watch(moduleRepositoryProvider).fetchCourseModules(courseId);
});

final moduleProvider = FutureProvider.family<Module?, String>((ref, moduleId) async {
  return ref.watch(moduleRepositoryProvider).fetchModule(moduleId);
});

final moduleContentsProvider = FutureProvider.family<List<Content>, ({String courseId, String moduleId})>((ref, args) async {
  return ref.watch(moduleRepositoryProvider).fetchModuleContents(args.courseId, args.moduleId);
});
