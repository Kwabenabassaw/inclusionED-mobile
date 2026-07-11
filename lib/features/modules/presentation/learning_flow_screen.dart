import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/modules/data/module_repository.dart';
import 'package:inclusive_ed_student/features/quizzes/data/quiz_repository.dart';
import 'package:inclusive_ed_student/features/courses/data/course_repository.dart';
import 'package:inclusive_ed_student/shared/models/module.dart';
import 'package:inclusive_ed_student/shared/models/quiz.dart';
import 'package:inclusive_ed_student/shared/models/enrollment.dart';

// Components for the flow
import 'components/learning_flow_overview.dart';
import 'components/learning_flow_reader.dart';
import 'components/playback_controller.dart';
import 'components/learning_flow_summary.dart';
import 'components/learning_flow_completion.dart';
import 'quiz_screen.dart';

class LearningFlowScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String moduleId;

  const LearningFlowScreen({
    super.key,
    required this.courseId,
    required this.moduleId,
  });

  @override
  ConsumerState<LearningFlowScreen> createState() => _LearningFlowScreenState();
}

class _LearningFlowScreenState extends ConsumerState<LearningFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    // Safety net: force stop TTS when leaving the whole learning flow
    ref.read(playbackControllerProvider.notifier).stopForNavigation();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moduleAsync = ref.watch(moduleProvider(widget.moduleId));
    final quizzesAsync = ref.watch(moduleQuizzesProvider(widget.moduleId));
    final enrollmentAsync = ref.watch(activeEnrollmentStreamProvider(widget.courseId));

    return Scaffold(
      body: moduleAsync.when(
        data: (module) {
          if (module == null) {
            return _buildErrorState('Module not found.');
          }

          return quizzesAsync.when(
            data: (quizzes) {
              final quiz = quizzes.isNotEmpty ? quizzes.first : null;
              final enrollment = enrollmentAsync.asData?.value;
              
              return _buildFlow(module, quiz, enrollment);
            },
            loading: () => _buildLoadingState(),
            error: (e, st) => _buildErrorState('Failed to load quizzes: $e'),
          );
        },
        loading: () => _buildLoadingState(),
        error: (e, st) => _buildErrorState('Failed to load module: $e'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(message)),
    );
  }

  Widget _buildFlow(Module module, Quiz? quiz, Enrollment? enrollment) {
    final pages = [
      LearningFlowOverview(module: module),
      LearningFlowReader(courseId: widget.courseId, moduleId: widget.moduleId),
      LearningFlowSummary(module: module),
      if (quiz != null) QuizScreen(courseId: widget.courseId, quiz: quiz, embedded: true),
      LearningFlowCompletion(
        module: module,
        onComplete: () {
          _markModuleCompleted(module, enrollment);
          context.pop();
        },
      ),
    ];

    final totalPages = pages.length;
    final isFirstPage = _currentPage == 0;
    final isLastPage = _currentPage == totalPages - 1;
    // Don't show bottom bar on Quiz screen if we want quiz to manage its own submit button,
    // but QuizScreen requires answers. For now, let's keep the flow controller at the bottom.
    final isQuizPage = quiz != null && _currentPage == 3;

    return Column(
      children: [
        // Custom App Bar
        SafeArea(
          bottom: false,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    // Safety net: force stop TTS on explicit back navigation
                    ref.read(playbackControllerProvider.notifier).stopForNavigation();
                    context.pop();
                  },
                ),
                Expanded(
                  child: Text(
                    module.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_currentPage == 1) ...[
                  // Reading Controls (shown only on Reader page)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Text('Tt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                        ),
                        Container(width: 1, height: 20, color: Theme.of(context).colorScheme.outlineVariant),
                        IconButton(
                          icon: const Text('TT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          onPressed: () {},
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.primary),
                    onPressed: () {
                      // Handled inside LearningFlowReader if possible, or trigger accessibility modal
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
        
        // Top Progress Bar
        LinearProgressIndicator(
          value: (_currentPage + 1) / totalPages,
          minHeight: 4,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
        
        // Page Content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: isQuizPage ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(), // Prevent swiping past quiz without answering
            onPageChanged: (index) {
              // Silence audio immediately when swapping pages
              ref.read(playbackControllerProvider.notifier).stopForNavigation();
              setState(() {
                _currentPage = index;
              });
            },
            children: pages,
          ),
        ),
        
        // Bottom Navigation Bar (Hidden on Reader page since it has an audio player)
        if (_currentPage != 1)
          Container(
            padding: const EdgeInsets.all(AppDimensions.marginPage),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isFirstPage && !isLastPage && !isQuizPage)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                    
                  if (!isLastPage && !isQuizPage)
                    ElevatedButton.icon(
                      onPressed: () => _nextPage(totalPages),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  
                  if (isQuizPage)
                    const Expanded(
                      child: Text(
                        'Complete the quiz above to proceed',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    )
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _markModuleCompleted(Module module, Enrollment? enrollment) {
    if (enrollment == null) return;
    
    final progress = enrollment.progress ?? const EnrollmentProgress();
    final updatedIds = Set<String>.from(progress.completedModuleIds);
    updatedIds.add(module.id);
    
    ref.read(courseRepositoryProvider).updateEnrollmentProgress(
      enrollment.id, 
      progress.copyWith(completedModuleIds: updatedIds.toList())
    );
  }
}
