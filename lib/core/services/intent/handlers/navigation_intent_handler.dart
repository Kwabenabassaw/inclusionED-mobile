import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/services/intent/handlers/intent_handler.dart';

class NavigationIntentHandler implements IntentHandler {
  @override
  List<String> get supportedActions => [
        'login',
        'openDashboard',
        'openCalendar',
        'openNotifications',
        'openProfile',
        'openVoiceSettings',
        'openSmartReader',
        'openCourses',
        'openSettings',
        'search',
        'goBack',
      ];

  @override
  Future<void> handle(IntentContext context) async {
    final tts = context.fallbackTts;
    final playback = context.playbackController;
    final ctx = context.buildContext;

    switch (context.action) {
      case 'login':
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/login');
        break;

      case 'openDashboard':
        await tts.speak("Opening dashboard");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/dashboard');
        break;

      case 'openCalendar':
        await tts.speak("Opening calendar");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/calendar');
        break;

      case 'openNotifications':
        await tts.speak("Opening notifications");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/notifications');
        break;

      case 'openProfile':
      case 'openSettings':
        await tts.speak(context.action == 'openSettings' ? "Opening settings" : "Opening profile");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/profile');
        break;

      case 'openVoiceSettings':
        await tts.speak("Opening voice settings");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/profile/voice-settings');
        break;

      case 'openSmartReader':
        await tts.speak("Opening smart audio reader");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/profile/accessible-reader');
        break;

      case 'openCourses':
        await tts.speak("Opening your courses");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/courses');
        break;
        
      case 'search':
        await tts.speak("Opening search for ${context.target ?? ''}");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        ctx.go('/courses');
        break;

      case 'goBack':
        await tts.speak("Going back");
        await playback.stopForNavigation();
        if (!ctx.mounted) return;
        if (ctx.canPop()) {
          ctx.pop();
        } else {
          ctx.go('/dashboard');
        }
        break;
    }
  }
}
