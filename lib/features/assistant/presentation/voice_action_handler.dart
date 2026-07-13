import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';
import 'package:opencampus_lms/features/courses/data/course_repository.dart';
import 'package:opencampus_lms/shared/models/course.dart';

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

  Future<void> handleAction(Map<String, dynamic>? actionData, BuildContext context, String screenText) async {
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
            await fallbackTts.speak("You are not enrolled in any active courses.");
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
            await fallbackTts.speak("I couldn't find a course matching $rawTarget.");
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
        final weekNum = actionData['target'];
        await fallbackTts.speak("Opening week $weekNum");
        await playbackController.stopForNavigation();
        if (!context.mounted) return;
        // Uses the current course/module logic in reality. Assuming 'current' or navigating root.
        context.go('/courses/current/modules/week-$weekNum'); 
        break;
        
      case 'readPage':
        // Feeds directly into the existing PlaybackData state machine
        if (screenText.isNotEmpty) {
          await playbackController.playOrResume(screenText);
        } else {
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
        if (!accessibilityController.state.darkMode) {
          accessibilityController.toggleDarkMode();
        }
        await fallbackTts.speak("Dark mode enabled.");
        break;

      case 'disableDarkMode':
        if (accessibilityController.state.darkMode) {
          accessibilityController.toggleDarkMode();
        }
        await fallbackTts.speak("Dark mode disabled.");
        break;

      case 'enableHighContrast':
        if (!accessibilityController.state.highContrast) {
          accessibilityController.toggleHighContrast();
        }
        await fallbackTts.speak("High contrast mode enabled.");
        break;

      case 'disableHighContrast':
        if (accessibilityController.state.highContrast) {
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
        if (ref.read(playbackControllerProvider).state == PlaybackState.speaking) {
          await playbackController.pause();
          await fallbackTts.speak("Reading paused.");
        } else {
          await fallbackTts.speak("Nothing is currently being read.");
        }
        break;

      case 'resumeReading':
        if (screenText.isNotEmpty) {
          await playbackController.playOrResume(screenText);
        } else {
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
        accessibilityController.applyPreset(AccessibilityPreset.visualImpairment);
        await fallbackTts.speak("Visual impairment mode enabled.");
        break;

      case 'presetMotor':
        accessibilityController.applyPreset(AccessibilityPreset.motorDifficulty);
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
        await _readSchedule(context, DateTime.now().add(const Duration(days: 1)), "tomorrow");
        break;

      default:
        await fallbackTts.speak("Sorry, I don't know how to do that yet.");
    }
  }

  Future<void> _readSchedule(BuildContext context, DateTime day, String dayName) async {
    try {
      await fallbackTts.speak("Checking your calendar for $dayName.");
      final events = await ref.read(upcomingEventsProvider.future);
      
      final dayEvents = events.where((e) {
        try {
          final date = DateTime.parse(e.startDate);
          return date.year == day.year && date.month == day.month && date.day == day.day;
        } catch (_) { return false; }
      }).toList();

      if (dayEvents.isEmpty) {
        await fallbackTts.speak("You don't have any events scheduled for $dayName.");
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
      await fallbackTts.speak("Sorry, I couldn't load your calendar right now.");
    }
  }

  String _formatSpeechTime(DateTime date) {
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute;
    if (minute == 0) {
      return '$hour $amPm';
    }
    return '$hour ${minute.toString().padLeft(2, '0')} $amPm';
  }
}
