import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';

class AnnouncementsList extends ConsumerWidget {
  const AnnouncementsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(recentAnnouncementsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Recent Announcements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppDimensions.stackSm),
        announcementsAsync.when(
          data: (announcements) {
            if (announcements.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.stackLg),
                  child: Center(
                    child: Text('No recent announcements.'),
                  ),
                ),
              );
            }

            return Column(
              children: announcements.map((announcement) {
                return Card(
                  margin: const EdgeInsets.only(bottom: AppDimensions.stackSm),
                  child: ListTile(
                    leading: Icon(Icons.campaign, color: Theme.of(context).colorScheme.primary),
                    title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${announcement.courseName} - ${announcement.body}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Show full announcement dialog or navigate
                    },
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error loading announcements: $err'),
        ),
      ],
    );
  }
}
