import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  void _nextPage(bool reduceMotion) {
    if (_currentPage < _totalPages - 1) {
      if (reduceMotion) {
        _pageController.jumpToPage(_currentPage + 1);
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    } else {
      context.go('/login');
    }
  }

  void _skip() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(accessibilityProvider);
    final isHighContrast = settings.highContrast;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    Semantics(
                      label: 'Previous page',
                      button: true,
                      child: InkWell(
                        onTap: () {
                          if (settings.reduceMotion) {
                            _pageController.jumpToPage(_currentPage - 1);
                          } else {
                            _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.0 + settings.touchTargetMargin),
                          child: Icon(Icons.arrow_back,
                              color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 48),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 24 * settings.textScale,
                          height: 24 * settings.textScale,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 8 * settings.textScale),
                      Text(
                        'OpenCampus LMS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16 * settings.textScale,
                          fontFamily: settings.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14 * settings.textScale,
                        fontFamily: settings.fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: settings.reduceMotion ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildFeatureStep(
                    context,
                    settings,
                    isHighContrast,
                    icon: Icons.auto_stories,
                    title: 'Learn at your own pace',
                    description: 'Access courses and materials designed to adapt to your unique learning style.',
                  ),
                  _buildFeatureStep(
                    context,
                    settings,
                    isHighContrast,
                    icon: Icons.accessibility_new,
                    title: 'Fully Accessible',
                    description: 'Customize your reading experience, contrast, and navigation to suit your needs.',
                  ),
                  _buildFeatureStep(
                    context,
                    settings,
                    isHighContrast,
                    icon: Icons.mic,
                    title: 'Voice Commands',
                    description: 'Navigate and interact hands-free using our intelligent voice assistant.',
                    action: ElevatedButton.icon(
                      onPressed: () async {
                        final status = await Permission.microphone.request();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                status.isGranted 
                                    ? 'Microphone permission granted!' 
                                    : 'Microphone permission is required for voice commands.',
                                style: TextStyle(
                                  fontFamily: settings.fontFamily,
                                  fontSize: 14 * settings.textScale,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.mic_none),
                      label: Text(
                        'Enable Microphone',
                        style: TextStyle(
                          fontFamily: settings.fontFamily,
                          fontSize: 14 * settings.textScale,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer Navigation
            Container(
              padding: const EdgeInsets.all(AppDimensions.marginPage),
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pagination dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => Semantics(
                        label: 'Page ${index + 1} of $_totalPages',
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? (Theme.of(context).colorScheme.primary)
                                : (Theme.of(context).colorScheme.primaryContainer),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  Semantics(
                    button: true,
                    label: _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                    child: ElevatedButton(
                      onPressed: () => _nextPage(settings.reduceMotion),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16 + settings.touchTargetMargin),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _currentPage < _totalPages - 1 ? 'Next' : 'Get Started',
                        style: TextStyle(
                          fontSize: 16 * settings.textScale,
                          fontWeight: FontWeight.bold,
                          fontFamily: settings.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureStep(
    BuildContext context,
    AccessibilitySettings settings,
    bool isHighContrast, {
    required IconData icon,
    required String title,
    required String description,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.marginPage),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: title,
            image: true,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 80 * settings.textScale,

              ),
            ),
          ),
          SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: settings.fontFamily,
              height: settings.lineSpacing,
            ),
            textScaler: TextScaler.linear(settings.textScale),
          ),
          SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: settings.fontFamily,
              height: settings.lineSpacing,
            ),
            textScaler: TextScaler.linear(settings.textScale),
          ),
          if (action != null) ...[
            SizedBox(height: 24),
            action,
          ],
        ],
      ),
    );
  }
}
