import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:opencampus_lms/core/routing/app_router.dart';
import 'package:opencampus_lms/core/theme/app_theme.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/firebase_options.dart';
import 'package:responsive_scaler/responsive_scaler.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:opencampus_lms/features/notifications/data/fcm_service.dart';
import 'package:opencampus_lms/core/providers/wake_word_controller.dart';
import 'package:opencampus_lms/core/widgets/global_listening_indicator.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ResponsiveScaler.init(
    designWidth: 375,
    designHeight: 812,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        // ignore: deprecated_member_use
        androidProvider: AndroidProvider.debug,
        // ignore: deprecated_member_use
        appleProvider: AppleProvider.debug,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  await Supabase.initialize(
    url: 'https://qczgiqusaftwmdtkvctn.supabase.co',
    publishableKey: 'sb_publishable_O-y5A6h1K47N83cKfx6Blg_ZpFrmGn0',
  );

  try {
    await Hive.initFlutter();
    await Hive.openBox<String>('courses_cache');
    await Hive.openBox<String>('enrollments_cache');
    await Hive.openBox<String>('pending_learning_events');
    await Hive.openBox<String>('pending_quiz_submissions');
    await Hive.openBox<String>('pending_user_activity');
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
    // If Hive fails, we continue without offline caching instead of crashing.
  }
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const InclusiveEdStudentApp(),
    ),
  );
}

class InclusiveEdStudentApp extends ConsumerStatefulWidget {
  const InclusiveEdStudentApp({super.key});

  @override
  ConsumerState<InclusiveEdStudentApp> createState() => _InclusiveEdStudentAppState();
}

class _InclusiveEdStudentAppState extends ConsumerState<InclusiveEdStudentApp> {
  @override
  void initState() {
    super.initState();
    // Setup notification routing callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fcmService = ref.read(fcmServiceProvider);
      fcmService.setOnNotificationTapped((type, referenceId) {
        final router = ref.read(routerProvider);
        if (referenceId != null && referenceId.isNotEmpty) {
          switch (type.toUpperCase()) {
            case 'GRADE':
            case 'ANNOUNCEMENT':
            case 'NEW_WEEK':
            case 'ENROLLMENT':
            case 'COURSE_PUBLISHED':
              router.go('/courses/$referenceId');
              break;
            case 'LESSON':
              // Assuming referenceId is courseId:moduleId or just courseId
              // Let's route to courseId for now unless it has a colon
              final parts = referenceId.split(':');
              if (parts.length == 2) {
                router.go('/courses/${parts[0]}/modules/${parts[1]}');
              } else {
                router.go('/courses/$referenceId');
              }
              break;
            case 'ASSIGNMENT':
              // Route to course detail until assignment detail screen exists
              router.go('/courses/$referenceId');
              break;
            case 'CALENDAR_EVENT':
              router.go('/calendar');
              break;
            case 'QUIZ':
              // Assuming referenceId is courseId:quizId
              final parts = referenceId.split(':');
              if (parts.length == 2) {
                router.go('/courses/${parts[0]}/quizzes/${parts[1]}');
              } else {
                router.go('/courses/$referenceId');
              }
              break;
            default:
              router.go('/notifications');
          }
        } else {
          router.go('/notifications');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final goRouter = ref.watch(routerProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);
    
    // Eagerly initialize the wake word controller so it can listen to continuousListening
    ref.watch(wakeWordControllerProvider);

    return MaterialApp.router(
      title: 'OpenCampus LMS',

      theme: AppTheme.getTheme(accessibilitySettings),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(accessibilitySettings.textScale),
            boldText: accessibilitySettings.highContrast,
          ),
          child: Builder(
            builder: (contextWithMediaQuery) {
              return GlobalListeningIndicator(
                child: ResponsiveScaler.scale(
                  context: contextWithMediaQuery,
                  child: child!,
                  useMaxAccessibility: true,
                ),
              );
            },
          ),
        );
      },
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
