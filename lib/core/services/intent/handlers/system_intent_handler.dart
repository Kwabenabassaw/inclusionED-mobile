import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/services/intent/handlers/intent_handler.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/features/dashboard/data/dashboard_repository.dart';
import 'package:opencampus_lms/core/routing/app_router.dart';

class SystemIntentHandler implements IntentHandler {
  @override
  List<String> get supportedActions => [
        'help',
        'logout',
        'clearNotifications',
        'readScheduleToday',
        'readScheduleTomorrow',
        'whatsNext',
        'whereAmI',
        'whatCanISay',
      ];

  @override
  Future<void> handle(IntentContext context) async {
    final tts = context.fallbackTts;
    final playback = context.playbackController;
    final ctx = context.buildContext;
    final ref = context.ref;

    switch (context.action) {
      case 'help':
        await tts.speak("You can say things like open dashboard, read this page, or go back.");
        break;

      case 'logout':
        await tts.speak("Logging out");
        await playback.stopForNavigation();
        await ref.read(authRepositoryProvider).signOut();
        if (!ctx.mounted) return;
        ctx.go('/login');
        break;

      case 'clearNotifications':
        await tts.speak("Notifications cleared.");
        break;

      case 'readScheduleToday':
        await _readSchedule(context, DateTime.now(), "today");
        break;

      case 'readScheduleTomorrow':
        await _readSchedule(context, DateTime.now().add(const Duration(days: 1)), "tomorrow");
        break;

      case 'whatsNext':
        await _readSchedule(context, DateTime.now(), "next");
        break;

      case 'whereAmI':
        final location = ref.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
        await tts.speak("You are currently on the $location screen.");
        break;

      case 'whatCanISay':
        final location = ref.read(routerProvider).routerDelegate.currentConfiguration.uri.path;
        if (location.startsWith('/courses/')) {
          await tts.speak("You can say 'next lesson', 'explain this lesson', or 'go back'.");
        } else {
          await tts.speak("You can say 'open my courses', 'open calendar', or 'open settings'.");
        }
        break;
    }
  }

  Future<void> _readSchedule(IntentContext context, DateTime day, String dayName) async {
    final tts = context.fallbackTts;
    try {
      await tts.speak("Checking your calendar for $dayName.");
      final events = await context.ref.read(upcomingEventsProvider.future);

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
        await tts.speak("You don't have any events scheduled for $dayName.");
      } else {
        String scheduleText = "You have ${dayEvents.length} events $dayName. ";
        for (final event in dayEvents) {
          final start = DateTime.parse(event.startDate);
          final timeStr = _formatSpeechTime(start);
          scheduleText += "At $timeStr, ${event.title}. ";
        }
        await tts.speak(scheduleText);
      }
    } catch (e) {
      await tts.speak("Sorry, I couldn't load your calendar right now.");
    }
  }

  String _formatSpeechTime(DateTime date) {
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute;
    if (minute == 0) return '$hour $amPm';
    return '$hour ${minute.toString().padLeft(2, '0')} $amPm';
  }
}
