import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/core/data/resource_repository.dart';
import 'package:inclusive_ed_student/shared/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

final courseContentsProvider = StreamProvider.family<List<Content>, String>((ref, courseId) {
  final query = FirebaseFirestore.instance
      .collection('contents')
      .where('courseId', isEqualTo: courseId)
      .where('type', whereIn: ['file', 'link']);

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Content.fromJson(data);
    }).toList();
  });
});

class CourseResourcesTab extends ConsumerWidget {
  final String courseId;

  const CourseResourcesTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncContents = ref.watch(courseContentsProvider(courseId));

    return asyncContents.when(
      data: (contents) {
        if (contents.isEmpty) {
          return const Center(child: Text('No resources available for this course yet.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final content = contents[index];
            final isPdf = content.type == 'file' && (
              (content.fileName?.toLowerCase().endsWith('.pdf') == true) || 
              (content.fileUrl?.toLowerCase().contains('.pdf') == true)
            );
            
            return Card(
              margin: const EdgeInsets.only(bottom: AppDimensions.stackMd),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.stackLg, vertical: AppDimensions.stackSm),
                leading: Icon(
                  content.type == 'link' ? Icons.link : 
                  isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                title: Text(
                  content.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  content.type.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Icon(
                  isPdf ? Icons.fullscreen : Icons.open_in_new,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onTap: () async {
                  final urlString = content.type == 'link' ? content.linkUrl : content.fileUrl;
                  if (urlString == null || urlString.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File is still processing or link is missing.')),
                      );
                    }
                    return;
                  }
                  
                  String finalUrl = urlString;
                    
                    // Fetch signed URL if it's a Supabase storage path and not an external HTTP link
                    if (content.type == 'file' && !urlString.startsWith('http')) {
                      try {
                        final repo = ref.read(resourceRepositoryProvider);
                        finalUrl = await repo.getSignedUrl(urlString);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to load file: $e')),
                          );
                        }
                        return;
                      }
                    }

                    if (isPdf) {
                      if (context.mounted) {
                        context.push('/courses/$courseId/pdf', extra: {
                          'title': content.title,
                          'url': finalUrl,
                        });
                      }
                    } else {
                      final url = Uri.parse(finalUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading resources: $e')),
    );
  }
}
