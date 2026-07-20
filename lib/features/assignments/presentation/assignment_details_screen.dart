import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'dart:io';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/assignments/data/assignment_repository.dart';
import 'package:opencampus_lms/shared/models/assignment.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:intl/intl.dart';

class AssignmentDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String assignmentId;

  const AssignmentDetailsScreen({
    super.key,
    required this.courseId,
    required this.assignmentId,
  });

  @override
  ConsumerState<AssignmentDetailsScreen> createState() => _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends ConsumerState<AssignmentDetailsScreen> {
  bool _isUploading = false;
  
  Future<void> _handleFileUpload(Assignment assignment, String studentId) async {
    try {
      final result = await fp.FilePicker.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'zip'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        
        final file = File(result.files.single.path!);
        final repo = ref.read(assignmentRepositoryProvider);
        
        await repo.submitAssignment(
          assignmentId: assignment.id,
          studentId: studentId,
          file: file,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment submitted successfully!')),
          );
          // Refresh the submission provider
          ref.invalidate(assignmentSubmissionProvider((assignmentId: assignment.id, studentId: studentId)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    if (user == null) return const Scaffold(body: Center(child: Text('User not found')));

    final asyncAssignments = ref.watch(courseAssignmentsProvider(widget.courseId));
    final asyncSubmission = ref.watch(assignmentSubmissionProvider((assignmentId: widget.assignmentId, studentId: user.uid)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncAssignments.when(
        data: (assignments) {
          final assignment = assignments.firstWhere(
            (a) => a.id == widget.assignmentId,
            orElse: () => throw Exception('Assignment not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.stackLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.stackMd),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Due: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(assignment.dueDate))}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${assignment.totalPoints} pts',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.stackLg),
                const Divider(),
                const SizedBox(height: AppDimensions.stackLg),
                Text(
                  'Instructions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppDimensions.stackSm),
                Text(
                  assignment.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppDimensions.stackXl),
                
                // Submission Area
                Container(
                  padding: const EdgeInsets.all(AppDimensions.stackLg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: asyncSubmission.when(
                    data: (submission) {
                      if (submission == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Your Work',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: AppDimensions.stackMd),
                            const Text('No work submitted yet.'),
                            const SizedBox(height: AppDimensions.stackLg),
                            ElevatedButton.icon(
                              onPressed: _isUploading ? null : () => _handleFileUpload(assignment, user.uid),
                              icon: _isUploading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.upload_file),
                              label: Text(_isUploading ? 'Uploading...' : 'Submit File'),
                            ),
                          ],
                        );
                      }

                      // Has submitted
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Work',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Chip(
                                label: Text(submission.status),
                                backgroundColor: submission.status == 'GRADED' 
                                  ? Colors.green.withValues(alpha: 0.2) 
                                  : Colors.blue.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.stackMd),
                          ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(submission.submittedFileName),
                            subtitle: Text('Submitted: ${DateFormat.yMMMd().add_jm().format(DateTime.parse(submission.submittedAt))}'),
                            contentPadding: EdgeInsets.zero,
                          ),
                          
                          if (submission.status == 'GRADED') ...[
                            const Divider(),
                            const SizedBox(height: AppDimensions.stackSm),
                            Text(
                              'Grade: ${submission.grade} / ${assignment.totalPoints}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
                              const SizedBox(height: AppDimensions.stackSm),
                              const Text('Feedback:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(submission.feedback!),
                            ]
                          ]
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Text('Error loading submission: $e'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading assignment: $e')),
      ),
    );
  }
}
