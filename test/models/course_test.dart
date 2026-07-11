import 'package:flutter_test/flutter_test.dart';
import 'package:inclusive_ed_student/shared/models/course.dart';

void main() {
  group('Course Model Tests', () {
    test('Course.fromJson properly deserializes data', () {
      final Map<String, dynamic> json = {
        'id': 'c1',
        'code': 'CS101',
        'name': 'Intro to CS',
        'description': 'A beginner course',
        'department': 'Computer Science',
        'level': 'Beginner',
        'term': 'Fall 2026',
        'published': true,
        'archived': false,
        'studentsCount': 100,
        'accessibilityScore': 95,
        'createdAt': '2026-07-01T00:00:00Z',
        'instructorId': 'i1',
      };

      final course = Course.fromJson(json);

      expect(course.id, 'c1');
      expect(course.code, 'CS101');
      expect(course.published, true);
      expect(course.accessibilityScore, 95);
    });
  });
}
