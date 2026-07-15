import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/widgets/main_scaffold.dart';
import 'package:opencampus_lms/core/routing/go_router_refresh_stream.dart';
import 'package:opencampus_lms/features/authentication/data/auth_repository.dart';
import 'package:opencampus_lms/features/authentication/presentation/login_screen.dart';
import 'package:opencampus_lms/features/authentication/presentation/signup_screen.dart';
import 'package:opencampus_lms/features/onboarding/presentation/onboarding_screen.dart';
import 'package:opencampus_lms/features/onboarding/presentation/splash_screen.dart';
import 'package:opencampus_lms/features/onboarding/presentation/welcome_screen.dart';
import 'package:opencampus_lms/features/dashboard/presentation/dashboard_screen.dart';
import 'package:opencampus_lms/features/courses/presentation/courses_screen.dart';
import 'package:opencampus_lms/features/courses/presentation/course_details_screen.dart';
import 'package:opencampus_lms/features/courses/presentation/pdf_viewer_screen.dart';
import 'package:opencampus_lms/features/modules/presentation/learning_flow_screen.dart';
import 'package:opencampus_lms/features/modules/presentation/quiz_player_wrapper.dart';
import 'package:opencampus_lms/features/assistant/presentation/assistant_screen.dart';
import 'package:opencampus_lms/features/calendar/presentation/calendar_screen.dart';
import 'package:opencampus_lms/features/notifications/presentation/notifications_screen.dart';
import 'package:opencampus_lms/features/profile/presentation/profile_screen.dart';
import 'package:opencampus_lms/features/accessibility/smart_audio_reader_screen.dart';
import 'package:opencampus_lms/features/profile/presentation/voice_settings_screen.dart';
import 'package:opencampus_lms/features/reader/screens/accessible_reader_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Provide the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authRepository.authStateChanges),
    redirect: (context, state) {
      final isAuthenticated = authRepository.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSigningUp = state.matchedLocation == '/signup';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/splash';
      final isWelcome = state.matchedLocation == '/welcome';

      // Unauthenticated users can only be on splash, welcome, login, signup, or onboarding
      if (!isAuthenticated && !isLoggingIn && !isSigningUp && !isOnboarding && !isSplash && !isWelcome) {
        return '/splash'; 
      }
      
      // Authenticated users shouldn't see auth/onboarding flows
      if (isAuthenticated && (isLoggingIn || isSigningUp || isOnboarding || isSplash || isWelcome)) {
        return '/dashboard'; 
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) {
          final courseId = state.uri.queryParameters['courseId'];
          return AssistantScreen(courseId: courseId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/courses',
                builder: (context, state) => const CoursesScreen(),
                routes: [
                  GoRoute(
                    path: ':courseId',
                    builder: (context, state) => CourseDetailsScreen(
                      courseId: state.pathParameters['courseId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'modules/:moduleId',
                        builder: (context, state) => LearningFlowScreen(
                          courseId: state.pathParameters['courseId']!,
                          moduleId: state.pathParameters['moduleId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'quizzes/:quizId',
                        builder: (context, state) => QuizPlayerWrapper(
                          courseId: state.pathParameters['courseId']!,
                          quizId: state.pathParameters['quizId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'pdf',
                        builder: (context, state) {
                          final extra = state.extra as Map<String, dynamic>? ?? {};
                          return PdfViewerScreen(
                            title: extra['title'] as String? ?? 'PDF Document',
                            pdfUrl: extra['url'] as String? ?? '',
                          );
                        },
                      ),
                      GoRoute(
                        path: 'reader/:moduleId',
                        builder: (context, state) => AccessibleReaderScreen(
                          courseId: state.pathParameters['courseId']!,
                          moduleId: state.pathParameters['moduleId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'accessible-reader',
                    builder: (context, state) => const SmartAudioReaderScreen(),
                  ),
                  GoRoute(
                    path: 'voice-settings',
                    builder: (context, state) => const VoiceSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
