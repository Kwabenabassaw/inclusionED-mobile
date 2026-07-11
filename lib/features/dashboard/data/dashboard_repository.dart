import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_ed_student/features/authentication/data/auth_repository.dart';
import 'package:inclusive_ed_student/shared/models/announcement.dart';
import 'package:inclusive_ed_student/shared/models/calendar_event.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    FirebaseFirestore.instance,
    ref.watch(authRepositoryProvider),
  );
});

class DashboardRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DashboardRepository(this._firestore, this._authRepository);

  Future<List<String>> _getEnrolledCourseIds() async {
    final user = _authRepository.currentUser;
    if (user == null) return [];

    final query = await _firestore
        .collection('enrollments')
        .where('studentId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'ACTIVE')
        .get();

    return query.docs.map((doc) => doc.data()['courseId'] as String).toList();
  }

  Stream<List<Announcement>> getRecentAnnouncements() async* {
    final courseIds = await _getEnrolledCourseIds();
    if (courseIds.isEmpty) {
      yield [];
      return;
    }

    final chunk = courseIds.take(10).toList(); // Firestore whereIn limit is 10
    
    final query = _firestore
        .collection('announcements')
        .where('courseId', whereIn: chunk)
        .orderBy('createdAt', descending: true);

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.take(5).map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Announcement.fromJson(data);
      }).toList();
    });
  }

  Stream<List<CalendarEvent>> getUpcomingEvents() async* {
    final courseIds = await _getEnrolledCourseIds();
    if (courseIds.isEmpty) {
      yield [];
      return;
    }

    final chunk = courseIds.take(10).toList();

    final query = _firestore
        .collection('calendarEvents')
        .where('courseId', whereIn: chunk)
        .where('isPublished', isEqualTo: true)
        .orderBy('startDate');

    yield* query.snapshots().map((snapshot) {
      final now = DateTime.now().subtract(const Duration(hours: 24)); // Include recent
      
      final docs = snapshot.docs.where((doc) {
        final data = doc.data();
        final endDateStr = data['endDate'] as String? ?? '';
        if (endDateStr.isEmpty) return false;
        return DateTime.parse(endDateStr).isAfter(now);
      }).toList();

      return docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CalendarEvent.fromJson(data);
      }).toList();
    });
  }
}

final recentAnnouncementsProvider = StreamProvider<List<Announcement>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getRecentAnnouncements();
});

final upcomingEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  return ref.watch(dashboardRepositoryProvider).getUpcomingEvents();
});
