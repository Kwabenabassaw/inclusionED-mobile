import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/shared/models/announcement.dart';

final courseAnnouncementsProvider = StreamProvider.family<List<Announcement>, String>((ref, courseId) {
  final query = FirebaseFirestore.instance
      .collection('announcements')
      .where('courseId', isEqualTo: courseId);

  return query.snapshots().map((snapshot) {
    final docs = snapshot.docs;
    
    docs.sort((a, b) {
      final dateA = DateTime.tryParse(a.data()['createdAt'] as String? ?? '') ?? DateTime.now();
      final dateB = DateTime.tryParse(b.data()['createdAt'] as String? ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA); // Descending
    });

    return docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Announcement.fromJson(data);
    }).toList();
  });
});

class CourseAnnouncementsTab extends ConsumerWidget {
  final String courseId;

  const CourseAnnouncementsTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAnnouncements = ref.watch(courseAnnouncementsProvider(courseId));

    return asyncAnnouncements.when(
      data: (announcements) {
        if (announcements.isEmpty) {
          return const Center(child: Text('No announcements yet.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.stackLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign),
                        const SizedBox(width: AppDimensions.stackSm),
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.stackLg),
                    Text(
                      'Posted by ${announcement.instructorName} on ${DateTime.parse(announcement.createdAt).toLocal().toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppDimensions.stackMd),
                    Text(announcement.body, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading announcements: $e')),
    );
  }
}
