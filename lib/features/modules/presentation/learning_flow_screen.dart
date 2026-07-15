import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/core/providers/global_fab_provider.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/features/quizzes/data/quiz_repository.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/module.dart';
import 'package:opencampus_lms/shared/models/quiz.dart';
import 'package:opencampus_lms/shared/models/enrollment.dart';

// Components for the flow
import 'components/learning_flow_overview.dart';
import 'components/learning_flow_reader.dart';
import 'components/playback_controller.dart';
import 'components/learning_flow_summary.dart';
import 'components/learning_flow_completion.dart';

import 'quiz_screen.dart';
import 'package:opencampus_lms/features/accessibility/presentation/display_settings_bottom_sheet.dart';
import 'package:opencampus_lms/features/modules/presentation/components/learning_flow_audio_dock.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';

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
  bool _isVisible = true;
  
  late final PlaybackController _playbackController;
  late final dynamic _hideGlobalFabController;

  @override
  void initState() {
    super.initState();
    _playbackController = ref.read(playbackControllerProvider.notifier);
    _hideGlobalFabController = ref.read(hideGlobalFabProvider.notifier);
  }

  @override
  void dispose() {
    // Safety net: force stop TTS when leaving the whole learning flow
    _playbackController.stopForNavigation();
    _hideGlobalFabController.state = false;
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

    return VisibilityDetector(
      key: const Key('learning_flow_screen_visibility'),
      onVisibilityChanged: (info) {
        if (!mounted) return;
        final isVisible = info.visibleFraction > 0;
        if (_isVisible != isVisible) {
          _isVisible = isVisible;
          if (!_isVisible) {
            // Screen is no longer visible (e.g. user navigated to a different tab)
            // Ensure FAB is restored.
            ref.read(hideGlobalFabProvider.notifier).state = false;
          } else {
            // Screen is visible again, apply current page logic
            final isQuizPage = quizzesAsync.asData?.value.isNotEmpty == true && _currentPage == 3;
            ref.read(hideGlobalFabProvider.notifier).state = isQuizPage;
          }
        }
      },
      child: Scaffold(
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(
        child: Semantics(
          label: message,
          child: Text(message),
        ),
      ),
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
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isVisible) {
        final currentlyHidden = ref.read(hideGlobalFabProvider);
        if (currentlyHidden != isQuizPage) {
          ref.read(hideGlobalFabProvider.notifier).state = isQuizPage;
        }
      }
    });

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
                  tooltip: 'Back to course',
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
                if (_currentPage <= 1) ...[
                  // Reading Controls (shown only on Reader and Overview pages)
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                   
                  // ),
                  SizedBox(width: 8),
                  Semantics(
                    button: true,
                    label: 'Display settings',
                    child: IconButton(
                      icon: Icon(Icons.text_fields_rounded, color: Theme.of(context).colorScheme.primary),
                      tooltip: 'Display Settings',
                      onPressed: () {
                        showDisplaySettingsBottomSheet(context);
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
        
        // Top Progress Bar
        Semantics(
          label: 'Learning Progress: Page ${_currentPage + 1} of $totalPages',
          child: ExcludeSemantics(
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / totalPages,
              minHeight: 4,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        
        // Page Content
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: isQuizPage ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(), // Prevent swiping past quiz without answering
            onPageChanged: (index) {
              // Silence audio immediately when swapping pages
              ref.read(playbackControllerProvider.notifier).stopForNavigation();
              ref.read(currentReadableTextProvider.notifier).state = '';
              setState(() {
                _currentPage = index;
              });
            },
            children: pages,
          ),
        ),
        
        // Bottom Navigation Bar
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
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isFirstPage && !isLastPage && !isQuizPage)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Back'),
                    )
                  else
                    SizedBox.shrink(),
                    
                  if (!isLastPage && !isQuizPage)
                    ElevatedButton.icon(
                      onPressed: () => _nextPage(totalPages),
                      icon: Icon(Icons.arrow_forward),
                      label: Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  
                  if (isQuizPage)
                    Expanded(
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
          
        // Global Audio Dock
        const SafeArea(
          top: false,
          child: LearningFlowAudioDock(),
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
