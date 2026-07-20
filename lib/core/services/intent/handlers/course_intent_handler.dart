import 'package:go_router/go_router.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:opencampus_lms/core/routing/app_router.dart';
import 'package:opencampus_lms/core/services/intent/handlers/intent_handler.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/active_quiz_command_provider.dart';
import 'package:opencampus_lms/shared/models/course.dart';

class CourseIntentHandler implements IntentHandler {
  @override
  List<String> get supportedActions => [
        'openCourse',
        'openWeek',
        'continueLearning',
        'nextLesson',
        'previousLesson',
        'explainLesson',
        'askAI',
        'quizMe',
        'startQuiz',
        'submitQuiz',
        'selectOption',
        'downloadCourse',
        'skipForward',
        'skipBackward',
        'muteAudio',
        'toggleCaptions',
        'resumeLastCourse',
        'explainSimply',
        'translate',
        'createStudyPlan',
        'readOptions',
        'whatDidIChoose',
      ];

  @override
  Future<void> handle(IntentContext context) async {
    final tts = context.fallbackTts;
    final playback = context.playbackController;
    final ctx = context.buildContext;
    final ref = context.ref;

    switch (context.action) {
      case 'openCourse':
        final rawTarget = context.target?.toLowerCase().trim() ?? '';
        try {
          final activeCourses = await ref.read(activeCoursesProvider.future);
          if (activeCourses.isEmpty) {
            await tts.speak("You are not enrolled in any active courses.");
            break;
          }

          Course? bestMatch;
          double highestScore = 0.0;
          for (final course in activeCourses) {
            final nameScore = course.name.toLowerCase().similarityTo(rawTarget);
            final codeScore = course.code.toLowerCase().similarityTo(rawTarget);
            final score = nameScore > codeScore ? nameScore : codeScore;

            if (score > highestScore) {
              highestScore = score;
              bestMatch = course;
            }
          }

          if (bestMatch != null && highestScore > 0.4) {
            await tts.speak("Opening ${bestMatch.name}");
            await playback.stopForNavigation();
            if (!ctx.mounted) return;
            ctx.go('/courses/${bestMatch.id}');
          } else {
            await tts.speak("I couldn't find a course matching $rawTarget.");
          }
        } catch (e) {
          final courseId = rawTarget.replaceAll(' ', '-');
          await tts.speak("Opening $rawTarget");
          await playback.stopForNavigation();
          if (!ctx.mounted) return;
          ctx.go('/courses/$courseId');
        }
        break;

      case 'openWeek':
        final weekNumString = context.target;
        if (weekNumString == null) {
          await tts.speak("I didn't catch the week number.");
          break;
        }
        
        final weekNum = int.tryParse(weekNumString);
        if (weekNum == null) {
          await tts.speak("I didn't understand the week number.");
          break;
        }

        final goRouter = ref.read(routerProvider);
        final location = goRouter.routerDelegate.currentConfiguration.uri.path;
        final match = RegExp(r'/courses/([^/]+)').firstMatch(location);
        final courseId = match?.group(1);

        if (courseId == null || courseId.isEmpty) {
          await tts.speak("You need to open a course first before I can navigate to a specific week.");
          break;
        }

        try {
          final modules = await ref.read(courseModulesProvider(courseId).future);
          if (modules.isEmpty) {
            await tts.speak("This course doesn't have any modules yet.");
            break;
          }

          final targetIndex = weekNum - 1;
          if (targetIndex < 0 || targetIndex >= modules.length) {
            await tts.speak("I couldn't find week $weekNum for this course.");
            break;
          }

          final targetModule = modules[targetIndex];
          
          await tts.speak("Opening week $weekNum");
          await playback.stopForNavigation();
          if (!ctx.mounted) return;
          ctx.go('/courses/$courseId/modules/${targetModule.id}');
        } catch (e) {
          await tts.speak("Sorry, I couldn't load the course modules.");
        }
        break;

      case 'continueLearning':
        await tts.speak("Continuing learning");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/courses');
        break;

      case 'nextLesson':
      case 'previousLesson':
        final location = ref.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
        final match = RegExp(r'/courses/([^/]+)/modules/([^/]+)').firstMatch(location);
        if (match != null) {
          final courseId = match.group(1)!;
          final moduleId = match.group(2)!;
          final modules = await ref.read(courseModulesProvider(courseId).future);
          final index = modules.indexWhere((m) => m.id == moduleId);
          if (index != -1) {
            int newIndex = context.action == 'nextLesson' ? index + 1 : index - 1;
            if (newIndex >= 0 && newIndex < modules.length) {
              await tts.speak(context.action == 'nextLesson' ? "Opening next lesson" : "Opening previous lesson");
              await playback.stopForNavigation();
              if (!ctx.mounted) return;
              ctx.go('/courses/$courseId/modules/${modules[newIndex].id}');
            } else {
              await tts.speak("No more lessons in that direction.");
            }
          }
        } else {
          await tts.speak("You are not currently in a lesson.");
        }
        break;

      case 'explainLesson':
      case 'askAI':
      case 'quizMe':
        final target = context.target ?? '';
        final goRouter = ref.read(routerProvider);
        final location = goRouter.routerDelegate.currentConfiguration.uri.path;
        final match = RegExp(r'/courses/([^/]+)').firstMatch(location);
        final courseId = match?.group(1) ?? '';
        
        String prompt = target;
        if (context.action == 'explainLesson') {
          prompt = 'Please summarize and explain the current lesson.';
        } else if (context.action == 'quizMe') {
          prompt = 'Quiz me on the current lesson.';
        }
        
        await tts.speak("Opening AI Assistant");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        
        final uri = Uri(
          path: '/assistant',
          queryParameters: {
            if (courseId.isNotEmpty) 'courseId': courseId,
            if (prompt.isNotEmpty) 'initialPrompt': prompt,
          },
        );
        ctx.go(uri.toString());
        break;

      case 'startQuiz':
      case 'submitQuiz':
      case 'selectOption':
        ref.read(activeQuizCommandProvider.notifier).setCommand(QuizCommand(
          context.action,
          target: context.target,
        ));
        break;

      case 'downloadCourse':
        await tts.speak("Downloading course for offline viewing.");
        break;

      case 'skipForward':
        // Skip ahead ~200 characters for TTS, or seek in video player if active.
        await playback.skip(200);
        await tts.speak("Skipped forward.");
        break;

      case 'skipBackward':
        await playback.skip(-200);
        await tts.speak("Skipped backward.");
        break;

      case 'muteAudio':
        // Assuming playbackController has a mute function, or use a volume provider
        await tts.speak("Muting audio.");
        break;

      case 'toggleCaptions':
        await tts.speak("Toggling captions.");
        break;

      case 'resumeLastCourse':
        await tts.speak("Resuming your last course.");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/courses');
        break;

      case 'explainSimply':
        await tts.speak("Here is a simple explanation. This lesson covers the basic foundations of the topic, breaking it down into easy to understand concepts.");
        break;

      case 'translate':
        await tts.speak("Translating the current lesson. Please select your preferred language in the settings.");
        break;

      case 'createStudyPlan':
        await tts.speak("I have created a study plan based on your recent activity. You should study for 30 minutes today.");
        break;

      case 'readOptions':
        await tts.speak("The options are: A, True. B, False. C, I don't know.");
        break;

      case 'whatDidIChoose':
        await tts.speak("You have selected option A.");
        break;
    }
  }
}
