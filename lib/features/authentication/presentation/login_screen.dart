import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inclusive_ed_student/core/theme/app_dimensions.dart';
import 'package:inclusive_ed_student/features/authentication/presentation/auth_controller.dart';
import 'package:inclusive_ed_student/features/accessibility/data/accessibility_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck;
      });
      if (canCheck) {
        const storage = FlutterSecureStorage();
        final isBiometricEnabled = await storage.read(key: 'biometrics_enabled') == 'true';
        if (isBiometricEnabled && mounted) {
          _authenticateWithBiometrics();
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Biometrics check error: $e');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to sign in to InclusiveEd',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
      if (authenticated) {
        if (mounted) context.go('/dashboard');
      }
    } on PlatformException catch (e) {
      debugPrint('Biometrics auth error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    ref.read(authControllerProvider.notifier).signIn(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final settings = ref.watch(accessibilityProvider);
    final isHighContrast = settings.highContrast;

    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next.isSuccess) {
        if (_canCheckBiometrics) {
          const storage = FlutterSecureStorage();
          final isBiometricEnabled = await storage.read(key: 'biometrics_enabled') == 'true';
          
          if (!isBiometricEnabled && mounted) {
            final result = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: isHighContrast ? Colors.black : Theme.of(context).colorScheme.surface,
                title: Text(
                  'Enable Faster Login?',
                  style: TextStyle(color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.primary, fontFamily: settings.fontFamily),
                  textScaler: TextScaler.linear(settings.textScale),
                ),
                content: Text(
                  'Would you like to use Face ID or Fingerprint to sign in faster next time?',
                  style: TextStyle(color: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.onSurface, fontFamily: settings.fontFamily),
                  textScaler: TextScaler.linear(settings.textScale),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Not Now', style: TextStyle(color: isHighContrast ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16 * settings.textScale)),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.primary,
                      foregroundColor: isHighContrast ? Colors.black : Colors.white,
                    ),
                    child: Text('Enable', style: TextStyle(fontSize: 16 * settings.textScale, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            if (result == true) {
              await storage.write(key: 'biometrics_enabled', value: 'true');
            }
          }
        }
        if (mounted) context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: isHighContrast ? Colors.black : Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.marginPage),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Semantics(
                image: true,
                label: 'InclusiveEd Logo',
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.yellow.withOpacity(0.1) : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isHighContrast ? Colors.yellow : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.school_outlined,
                      size: 40 * settings.textScale,
                      color: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.primary,
                  fontFamily: settings.fontFamily,
                  height: settings.lineSpacing,
                ),
                textScaler: TextScaler.linear(settings.textScale),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue your personalized learning journey.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: settings.fontFamily,
                  height: settings.lineSpacing,
                ),
                textScaler: TextScaler.linear(settings.textScale),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: isHighContrast ? Colors.black : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHighContrast ? Colors.white54 : Theme.of(context).colorScheme.outlineVariant,
                    width: isHighContrast ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email Address',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontFamily: settings.fontFamily,
                      ),
                      textScaler: TextScaler.linear(settings.textScale),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      textField: true,
                      label: 'Enter email address',
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(
                          color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontFamily: settings.fontFamily,
                          fontSize: 16 * settings.textScale,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isHighContrast ? Colors.white54 : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          suffixIcon: Icon(Icons.email_outlined, color: isHighContrast ? Colors.white70 : null),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Password',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontFamily: settings.fontFamily,
                      ),
                      textScaler: TextScaler.linear(settings.textScale),
                    ),
                    const SizedBox(height: 8),
                    Semantics(
                      textField: true,
                      label: 'Enter password',
                      child: TextFormField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          fontFamily: settings.fontFamily,
                          fontSize: 16 * settings.textScale,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isHighContrast ? Colors.white54 : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          suffixIcon: Icon(Icons.lock_outline, color: isHighContrast ? Colors.white70 : null),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleSignIn(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (authState.errorMessage != null) ...[
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isHighContrast ? Colors.transparent : Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isHighContrast ? Colors.redAccent : Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: isHighContrast ? Colors.redAccent : Theme.of(context).colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Error: ${authState.errorMessage}',
                                  style: TextStyle(
                                    color: isHighContrast ? Colors.redAccent : Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: settings.fontFamily,
                                  ),
                                  textScaler: TextScaler.linear(settings.textScale),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Semantics(
                      button: true,
                      label: 'Sign In',
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 + settings.touchTargetMargin),
                          backgroundColor: isHighContrast ? Colors.yellow : Theme.of(context).colorScheme.primary,
                          foregroundColor: isHighContrast ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: authState.isLoading 
                            ? SizedBox(height: 20 * settings.textScale, width: 20 * settings.textScale, child: CircularProgressIndicator(color: isHighContrast ? Colors.black : Colors.white, strokeWidth: 2))
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign In', 
                                    style: TextStyle(
                                      fontSize: 16 * settings.textScale, 
                                      fontWeight: FontWeight.bold,
                                      fontFamily: settings.fontFamily,
                                    )
                                  ),
                                  SizedBox(width: 8 * settings.textScale),
                                  Icon(Icons.login, size: 20 * settings.textScale),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: Divider(color: isHighContrast ? Colors.white54 : Theme.of(context).colorScheme.outlineVariant)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR', 
                            style: TextStyle(
                              color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant, 
                              fontWeight: FontWeight.bold,
                              fontFamily: settings.fontFamily,
                            ),
                            textScaler: TextScaler.linear(settings.textScale),
                          ),
                        ),
                        Expanded(child: Divider(color: isHighContrast ? Colors.white54 : Theme.of(context).colorScheme.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      button: true,
                      label: 'Sign in with Google',
                      child: OutlinedButton(
                        onPressed: () => ref.read(authControllerProvider.notifier).signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16 + settings.touchTargetMargin),
                          side: BorderSide(
                            color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                            width: isHighContrast ? 2 : 1,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata, size: 32 * settings.textScale),
                            SizedBox(width: 8 * settings.textScale),
                            Text(
                              'Sign in with Google', 
                              style: TextStyle(
                                fontSize: 16 * settings.textScale, 
                                fontWeight: FontWeight.bold,
                                fontFamily: settings.fontFamily,
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_canCheckBiometrics) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        button: true,
                        label: 'Sign in with Biometrics (Face ID or Touch ID)',
                        child: OutlinedButton(
                          onPressed: _authenticateWithBiometrics,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16 + settings.touchTargetMargin),
                            side: BorderSide(
                              color: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              width: isHighContrast ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: isHighContrast ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint, size: 24 * settings.textScale),
                              SizedBox(width: 12 * settings.textScale),
                              Text(
                                'Use FaceID / TouchID', 
                                style: TextStyle(
                                  fontSize: 16 * settings.textScale, 
                                  fontWeight: FontWeight.bold,
                                  fontFamily: settings.fontFamily,
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
