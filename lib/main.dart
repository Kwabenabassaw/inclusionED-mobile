import 'package:flutter/material.dart';
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

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  ResponsiveScaler.init(
    designWidth: 375,
    designHeight: 812,
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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

class InclusiveEdStudentApp extends ConsumerWidget {
  const InclusiveEdStudentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    final accessibilitySettings = ref.watch(accessibilityProvider);

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
              return ResponsiveScaler.scale(
                context: contextWithMediaQuery,
                child: child!,
                useMaxAccessibility: true,
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
