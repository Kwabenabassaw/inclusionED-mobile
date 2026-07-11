import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inclusive_ed_student/core/routing/app_router.dart';
import 'package:inclusive_ed_student/core/theme/app_theme.dart';
import 'package:inclusive_ed_student/features/accessibility/data/accessibility_provider.dart';
import 'package:inclusive_ed_student/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  await Supabase.initialize(
    url: 'https://qczgiqusaftwmdtkvctn.supabase.co',
    anonKey: 'sb_publishable_O-y5A6h1K47N83cKfx6Blg_ZpFrmGn0',
  );

  await Hive.initFlutter();
  // TODO: Register Hive adapters and open boxes for offline mode

  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
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
      title: 'InclusiveEd Student',
      theme: AppTheme.getTheme(accessibilitySettings),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(accessibilitySettings.textScale),
            boldText: accessibilitySettings.highContrast,
          ),
          child: child!,
        );
      },
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
