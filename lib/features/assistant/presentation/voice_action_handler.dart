import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/course.dart';
import 'package:opencampus_lms/core/routing/app_router.dart';
import 'package:opencampus_lms/features/modules/data/module_repository.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/active_quiz_command_provider.dart';

class VoiceActionHandler {
  final PlaybackController playbackController;
  final UnifiedTtsController fallbackTts;
  final AccessibilityNotifier accessibilityController;
  final Ref ref;

  VoiceActionHandler({
    required this.playbackController,
    required this.fallbackTts,
    required this.accessibilityController,
    required this.ref,
  });

  Future<void> handleAction(
    Map<String, dynamic>? actionData,
    BuildContext context,
    String screenText,
  ) async {
    if (actionData == null) {
      await fallbackTts.speak("Sorry, I didn't catch that.");
      return;
    }

    switch (actionData['action']) {
      case 'login':
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/login');
        break;

      case 'openDashboard':
        await fallbackTts.speak("Opening dashboard");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/dashboard');
        break;

      case 'openCalendar':
        await fallbackTts.speak("Opening calendar");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/calendar');
        break;

      case 'openNotifications':
        await fallbackTts.speak("Opening notifications");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/notifications');
        break;

      case 'openProfile':
        await fallbackTts.speak("Opening profile");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/profile');
        break;

      case 'openVoiceSettings':
        await fallbackTts.speak("Opening voice settings");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/profile/voice-settings');
        break;

      case 'openSmartReader':
        await fallbackTts.speak("Opening smart audio reader");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/profile/accessible-reader');
        break;

      case 'openCourses':
        await fallbackTts.speak("Opening your courses");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/courses');
        break;

      case 'openCourse':
        final rawTarget = actionData['target'].toString().toLowerCase().trim();

        try {
          final activeCourses = await ref.read(activeCoursesProvider.future);

          if (activeCourses.isEmpty) {
            await fallbackTts.speak(
              "You are not enrolled in any active courses.",
            );
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
            await fallbackTts.speak("Opening ${bestMatch.name}");
            await playbackController.stopForNavigation();
            if (!context.mounted) return;
            context.go('/courses/${bestMatch.id}');
          } else {
            await fallbackTts.speak(
              "I couldn't find a course matching $rawTarget.",
            );
          }
        } catch (e) {
          // Fallback if provider fails
          final courseId = rawTarget.replaceAll(' ', '-');
          await fallbackTts.speak("Opening $rawTarget");
          await playbackController.stopForNavigation();
          if (!context.mounted) return;
          context.go('/courses/$courseId');
        }
        break;

      case 'openWeek':
        final weekNumString = actionData['target']?.toString();
        if (weekNumString == null) {
          await fallbackTts.speak("I didn't catch the week number.");
          break;
        }
        
        final weekNum = int.tryParse(weekNumString);
        if (weekNum == null) {
          await fallbackTts.speak("I didn't understand the week number.");
          break;
        }

        final goRouter = ref.read(routerProvider);
        final location = goRouter.routerDelegate.currentConfiguration.uri.path;
        final match = RegExp(r'/courses/([^/]+)').firstMatch(location);
        final courseId = match?.group(1);

        if (courseId == null || courseId.isEmpty) {
          await fallbackTts.speak("You need to open a course first before I can navigate to a specific week.");
          break;
        }

        try {
          final modules = await ref.read(courseModulesProvider(courseId).future);
          if (modules.isEmpty) {
            await fallbackTts.speak("This course doesn't have any modules yet.");
            break;
          }

          final targetIndex = weekNum - 1;
          if (targetIndex < 0 || targetIndex >= modules.length) {
            await fallbackTts.speak("I couldn't find week $weekNum for this course.");
            break;
          }

          final targetModule = modules[targetIndex];
          
          await fallbackTts.speak("Opening week $weekNum");
          await playbackController.stopForNavigation();
          if (!context.mounted) return;
          context.go('/courses/$courseId/modules/${targetModule.id}');
        } catch (e) {
          await fallbackTts.speak("Sorry, I couldn't load the course modules.");
        }
        break;

      case 'readPage':
        // Feeds directly into the existing PlaybackData state machine.
        // Skip if OS screen reader is active to prevent double-narration.
        if (screenText.isNotEmpty &&
            !ref.read(accessibilityProvider).screenReaderEnabled) {
          await playbackController.playOrResume(screenText);
        } else if (!ref.read(accessibilityProvider).screenReaderEnabled) {
          await fallbackTts.speak("There is no text to read on this page.");
        }
        break;

      case 'goBack':
        await fallbackTts.speak("Going back");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/dashboard');
        }
        break;

      case 'enableDarkMode':
        accessibilityController.toggleDarkMode();
        // Since toggle just flips it, we should explicitly set it to true if we had a setter.
        // For robustness, check if it's already on:
        if (!ref.read(accessibilityProvider).darkMode) {
          accessibilityController.toggleDarkMode();
        }
        await fallbackTts.speak("Dark mode enabled.");
        break;

      case 'disableDarkMode':
        if (ref.read(accessibilityProvider).darkMode) {
          accessibilityController.toggleDarkMode();
        }
        await fallbackTts.speak("Dark mode disabled.");
        break;

      case 'enableHighContrast':
        if (!ref.read(accessibilityProvider).highContrast) {
          accessibilityController.toggleHighContrast();
        }
        await fallbackTts.speak("High contrast mode enabled.");
        break;

      case 'disableHighContrast':
        if (ref.read(accessibilityProvider).highContrast) {
          accessibilityController.toggleHighContrast();
        }
        await fallbackTts.speak("High contrast mode disabled.");
        break;

      case 'setSpeedFast':
        await fallbackTts.setRate(1.5);
        accessibilityController.setPollySpeed(1.5);
        accessibilityController.setNativeSpeed(1.5);
        await fallbackTts.speak("Voice speed set to fast.");
        break;

      case 'setSpeedNormal':
        await fallbackTts.setRate(1.0);
        accessibilityController.setPollySpeed(1.0);
        accessibilityController.setNativeSpeed(1.0);
        await fallbackTts.speak("Voice speed set to normal.");
        break;

      case 'setSpeedSlow':
        await fallbackTts.setRate(0.5);
        accessibilityController.setPollySpeed(0.5);
        accessibilityController.setNativeSpeed(0.5);
        await fallbackTts.speak("Voice speed set to slow.");
        break;

      case 'pauseReading':
        if (ref.read(playbackControllerProvider).state ==
            PlaybackState.speaking) {
          await playbackController.pause();
          await fallbackTts.speak("Reading paused.");
        } else {
          await fallbackTts.speak("Nothing is currently being read.");
        }
        break;

      case 'resumeReading':
        // Skip if OS screen reader is active to prevent double-narration.
        if (screenText.isNotEmpty &&
            !ref.read(accessibilityProvider).screenReaderEnabled) {
          await playbackController.playOrResume(screenText);
        } else if (!ref.read(accessibilityProvider).screenReaderEnabled) {
          await fallbackTts.speak("There is no text to read on this page.");
        }
        break;

      case 'increaseTextSize':
        final currentScale = ref.read(accessibilityProvider).textScale;
        if (currentScale < 3.0) {
          accessibilityController.setTextScale(currentScale + 0.2);
          await fallbackTts.speak("Text size increased.");
        } else {
          await fallbackTts.speak("Text is already at maximum size.");
        }
        break;

      case 'decreaseTextSize':
        final currentScale = ref.read(accessibilityProvider).textScale;
        if (currentScale > 0.8) {
          accessibilityController.setTextScale(currentScale - 0.2);
          await fallbackTts.speak("Text size decreased.");
        } else {
          await fallbackTts.speak("Text is already at minimum size.");
        }
        break;

      case 'presetDyslexia':
        accessibilityController.applyPreset(AccessibilityPreset.dyslexia);
        await fallbackTts.speak("Dyslexia mode enabled.");
        break;

      case 'presetVisual':
        accessibilityController.applyPreset(
          AccessibilityPreset.visualImpairment,
        );
        await fallbackTts.speak("Visual impairment mode enabled.");
        break;

      case 'presetMotor':
        accessibilityController.applyPreset(
          AccessibilityPreset.motorDifficulty,
        );
        await fallbackTts.speak("Motor difficulty mode enabled.");
        break;

      case 'presetStandard':
        accessibilityController.applyPreset(AccessibilityPreset.standard);
        await fallbackTts.speak("Standard settings restored.");
        break;

      case 'readScheduleToday':
        await _readSchedule(context, DateTime.now(), "today");
        break;

      case 'readScheduleTomorrow':
        await _readSchedule(
          context,
          DateTime.now().add(const Duration(days: 1)),
          "tomorrow",
        );
        break;

      case 'continueLearning':
        await fallbackTts.speak("Continuing learning");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/courses');
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
            int newIndex = actionData['action'] == 'nextLesson' ? index + 1 : index - 1;
            if (newIndex >= 0 && newIndex < modules.length) {
              await fallbackTts.speak(actionData['action'] == 'nextLesson' ? "Opening next lesson" : "Opening previous lesson");
              await playbackController.stopForNavigation();
              if (!context.mounted) return;
              context.go('/courses/$courseId/modules/${modules[newIndex].id}');
            } else {
              await fallbackTts.speak("No more lessons in that direction.");
            }
          }
        } else {
          await fallbackTts.speak("You are not currently in a lesson.");
        }
        break;

      case 'explainLesson':
      case 'askAI':
      case 'quizMe':
        final target = actionData['target']?.toString() ?? '';
        final goRouter = ref.read(routerProvider);
        final location = goRouter.routerDelegate.currentConfiguration.uri.path;
        final match = RegExp(r'/courses/([^/]+)').firstMatch(location);
        final courseId = match?.group(1) ?? '';
        
        String prompt = target;
        if (actionData['action'] == 'explainLesson') {
          prompt = 'Please summarize and explain the current lesson.';
        } else if (actionData['action'] == 'quizMe') {
          prompt = 'Quiz me on the current lesson.';
        }
        
        await fallbackTts.speak("Opening AI Assistant");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        
        final uri = Uri(
          path: '/assistant',
          queryParameters: {
            if (courseId.isNotEmpty) 'courseId': courseId,
            if (prompt.isNotEmpty) 'initialPrompt': prompt,
          },
        );
        context.go(uri.toString());
        break;

      case 'stopSpeaking':
        await playbackController.pause();
        await fallbackTts.stop();
        break;

      case 'repeatThat':
        await fallbackTts.speak("Repeating the last sentence is not yet fully supported.");
        break;

      case 'readSlower':
        final currentSpeed1 = ref.read(accessibilityProvider).nativeSpeed;
        final newSpeed1 = (currentSpeed1 - 0.1).clamp(0.1, 2.0);
        await fallbackTts.setRate(newSpeed1);
        accessibilityController.setNativeSpeed(newSpeed1);
        accessibilityController.setPollySpeed(newSpeed1);
        await fallbackTts.speak("Reading slower.");
        break;

      case 'readFaster':
        final currentSpeed2 = ref.read(accessibilityProvider).nativeSpeed;
        final newSpeed2 = (currentSpeed2 + 0.1).clamp(0.1, 2.0);
        await fallbackTts.setRate(newSpeed2);
        accessibilityController.setNativeSpeed(newSpeed2);
        accessibilityController.setPollySpeed(newSpeed2);
        await fallbackTts.speak("Reading faster.");
        break;

      case 'openSettings':
        await fallbackTts.speak("Opening settings");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/profile');
        break;

      case 'search':
        await fallbackTts.speak("Opening search for ${actionData['target'] ?? ''}");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        context.go('/courses');
        break;

      case 'help':
        await fallbackTts.speak("You can say things like open dashboard, read this page, or go back.");
        break;

      case 'logout':
        await fallbackTts.speak("Logging out");
        await playbackController.stopForNavigation();
        await ref.read(authRepositoryProvider).signOut();
        if (!context.mounted) return;
        context.go('/login');
        break;

      case 'whatsNext':
        await _readSchedule(context, DateTime.now(), "next");
        break;

      case 'clearNotifications':
        await fallbackTts.speak("Notifications cleared.");
        break;

      case 'startQuiz':
      case 'submitQuiz':
      case 'selectOption':
        ref.read(activeQuizCommandProvider.notifier).setCommand(QuizCommand(
          actionData['action'],
          target: actionData['target']?.toString(),
        ));
        break;

      case 'downloadCourse':
        await fallbackTts.speak("Downloading course for offline viewing.");
        break;

      default:
        await fallbackTts.speak("Sorry, I don't know how to do that yet.");
    }
  }

  Future<void> _readSchedule(
    BuildContext context,
    DateTime day,
    String dayName,
  ) async {
    try {
      await fallbackTts.speak("Checking your calendar for $dayName.");
      final events = await ref.read(upcomingEventsProvider.future);

      final dayEvents = events.where((e) {
        try {
          final date = DateTime.parse(e.startDate);
          return date.year == day.year &&
              date.month == day.month &&
              date.day == day.day;
        } catch (_) {
          return false;
        }
      }).toList();

      if (dayEvents.isEmpty) {
        await fallbackTts.speak(
          "You don't have any events scheduled for $dayName.",
        );
      } else {
        String scheduleText = "You have ${dayEvents.length} events $dayName. ";
        for (final event in dayEvents) {
          final start = DateTime.parse(event.startDate);
          final timeStr = _formatSpeechTime(start);
          scheduleText += "At $timeStr, ${event.title}. ";
        }
        await fallbackTts.speak(scheduleText);
      }
    } catch (e) {
      await fallbackTts.speak(
        "Sorry, I couldn't load your calendar right now.",
      );
    }
  }

  String _formatSpeechTime(DateTime date) {
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute;
    if (minute == 0) {
      return '$hour $amPm';
    }
    return '$hour ${minute.toString().padLeft(2, '0')} $amPm';
  }
}
