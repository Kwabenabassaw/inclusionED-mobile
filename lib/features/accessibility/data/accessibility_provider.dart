import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccessibilityPreset { standard, dyslexia, visualImpairment, motorDifficulty }

class AccessibilitySettings {
  final AccessibilityPreset preset;
  final double textScale;
  final String fontFamily;
  final double lineSpacing;
  final bool boldText;
  final bool highContrast;
  final bool darkMode;
  final bool reduceMotion;
  final double readingSpeed;
  final String preferredVoice;
  final bool ttsHighlighting;
  final bool readingRuler;
  final double touchTargetMargin;
  final bool defaultToStt;
  final bool voiceCommandPersistent;
  final bool screenReaderEnabled;
  final String ttsEngine;
  final double pollySpeed;
  final double pollyPitch;
  final double pollyVolume;
  final String pollyVoice;
  final double nativeSpeed;
  final double nativePitch;
  final double nativeVolume;
  final String nativeVoice;

  const AccessibilitySettings({
    this.preset = AccessibilityPreset.standard,
    this.textScale = 1.0,
    this.fontFamily = 'System', // Will map to system font
    this.lineSpacing = 1.2,
    this.boldText = false,
    this.highContrast = false,
    this.darkMode = false,
    this.reduceMotion = false,
    this.readingSpeed = 1.0,
    this.preferredVoice = 'default',
    this.ttsHighlighting = false,
    this.readingRuler = false,
    this.touchTargetMargin = 0.0,
    this.defaultToStt = false,
    this.voiceCommandPersistent = false,
    this.screenReaderEnabled = false,
    this.ttsEngine = 'polly',
    this.pollySpeed = 1.0,
    this.pollyPitch = 1.0,
    this.pollyVolume = 1.0,
    this.pollyVoice = 'Joanna',
    this.nativeSpeed = 1.0,
    this.nativePitch = 1.0,
    this.nativeVolume = 1.0,
    this.nativeVoice = 'default',
  });

  AccessibilitySettings copyWith({
    AccessibilityPreset? preset,
    double? textScale,
    String? fontFamily,
    double? lineSpacing,
    bool? boldText,
    bool? highContrast,
    bool? darkMode,
    bool? reduceMotion,
    double? readingSpeed,
    String? preferredVoice,
    bool? ttsHighlighting,
    bool? readingRuler,
    double? touchTargetMargin,
    bool? defaultToStt,
    bool? voiceCommandPersistent,
    bool? screenReaderEnabled,
    String? ttsEngine,
    double? pollySpeed,
    double? pollyPitch,
    double? pollyVolume,
    String? pollyVoice,
    double? nativeSpeed,
    double? nativePitch,
    double? nativeVolume,
    String? nativeVoice,
  }) {
    return AccessibilitySettings(
      preset: preset ?? this.preset,
      textScale: textScale ?? this.textScale,
      fontFamily: fontFamily ?? this.fontFamily,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      boldText: boldText ?? this.boldText,
      highContrast: highContrast ?? this.highContrast,
      darkMode: darkMode ?? this.darkMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      readingSpeed: readingSpeed ?? this.readingSpeed,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      ttsHighlighting: ttsHighlighting ?? this.ttsHighlighting,
      readingRuler: readingRuler ?? this.readingRuler,
      touchTargetMargin: touchTargetMargin ?? this.touchTargetMargin,
      defaultToStt: defaultToStt ?? this.defaultToStt,
      voiceCommandPersistent: voiceCommandPersistent ?? this.voiceCommandPersistent,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      ttsEngine: ttsEngine ?? this.ttsEngine,
      pollySpeed: pollySpeed ?? this.pollySpeed,
      pollyPitch: pollyPitch ?? this.pollyPitch,
      pollyVolume: pollyVolume ?? this.pollyVolume,
      pollyVoice: pollyVoice ?? this.pollyVoice,
      nativeSpeed: nativeSpeed ?? this.nativeSpeed,
      nativePitch: nativePitch ?? this.nativePitch,
      nativeVolume: nativeVolume ?? this.nativeVolume,
      nativeVoice: nativeVoice ?? this.nativeVoice,
    );
  }
}

class AccessibilityNotifier extends Notifier<AccessibilitySettings> {
  @override
  AccessibilitySettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AccessibilitySettings(
      preset: AccessibilityPreset.values.firstWhere(
        (e) => e.name == prefs.getString('preset'),
        orElse: () => AccessibilityPreset.standard,
      ),
      textScale: prefs.getDouble('textScale') ?? 1.0,
      fontFamily: prefs.getString('fontFamily') ?? 'System',
      lineSpacing: prefs.getDouble('lineSpacing') ?? 1.2,
      boldText: prefs.getBool('boldText') ?? false,
      highContrast: prefs.getBool('highContrast') ?? false,
      darkMode: prefs.getBool('darkMode') ?? false,
      reduceMotion: prefs.getBool('reduceMotion') ?? false,
      readingSpeed: prefs.getDouble('readingSpeed') ?? 1.0,
      preferredVoice: prefs.getString('preferredVoice') ?? 'default',
      ttsHighlighting: prefs.getBool('ttsHighlighting') ?? false,
      readingRuler: prefs.getBool('readingRuler') ?? false,
      touchTargetMargin: prefs.getDouble('touchTargetMargin') ?? 0.0,
      defaultToStt: prefs.getBool('defaultToStt') ?? false,
      voiceCommandPersistent: prefs.getBool('voiceCommandPersistent') ?? false,
      screenReaderEnabled: prefs.getBool('screenReaderEnabled') ?? false,
      ttsEngine: prefs.getString('ttsEngine') ?? 'polly',
      pollySpeed: prefs.getDouble('pollySpeed') ?? 1.0,
      pollyPitch: prefs.getDouble('pollyPitch') ?? 1.0,
      pollyVolume: prefs.getDouble('pollyVolume') ?? 1.0,
      pollyVoice: prefs.getString('pollyVoice') ?? 'Joanna',
      nativeSpeed: prefs.getDouble('nativeSpeed') ?? 1.0,
      nativePitch: prefs.getDouble('nativePitch') ?? 1.0,
      nativeVolume: prefs.getDouble('nativeVolume') ?? 1.0,
      nativeVoice: prefs.getString('nativeVoice') ?? 'default',
    );
  }

  Future<void> updateSettings(AccessibilitySettings newSettings) async {
    state = newSettings;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('preset', newSettings.preset.name);
    await prefs.setDouble('textScale', newSettings.textScale);
    await prefs.setString('fontFamily', newSettings.fontFamily);
    await prefs.setDouble('lineSpacing', newSettings.lineSpacing);
    await prefs.setBool('boldText', newSettings.boldText);
    await prefs.setBool('highContrast', newSettings.highContrast);
    await prefs.setBool('darkMode', newSettings.darkMode);
    await prefs.setBool('reduceMotion', newSettings.reduceMotion);
    await prefs.setDouble('readingSpeed', newSettings.readingSpeed);
    await prefs.setString('preferredVoice', newSettings.preferredVoice);
    await prefs.setBool('ttsHighlighting', newSettings.ttsHighlighting);
    await prefs.setBool('readingRuler', newSettings.readingRuler);
    await prefs.setDouble('touchTargetMargin', newSettings.touchTargetMargin);
    await prefs.setBool('defaultToStt', newSettings.defaultToStt);
    await prefs.setBool('voiceCommandPersistent', newSettings.voiceCommandPersistent);
    await prefs.setBool('screenReaderEnabled', newSettings.screenReaderEnabled);
    await prefs.setString('ttsEngine', newSettings.ttsEngine);
    await prefs.setDouble('pollySpeed', newSettings.pollySpeed);
    await prefs.setDouble('pollyPitch', newSettings.pollyPitch);
    await prefs.setDouble('pollyVolume', newSettings.pollyVolume);
    await prefs.setString('pollyVoice', newSettings.pollyVoice);
    await prefs.setDouble('nativeSpeed', newSettings.nativeSpeed);
    await prefs.setDouble('nativePitch', newSettings.nativePitch);
    await prefs.setDouble('nativeVolume', newSettings.nativeVolume);
    await prefs.setString('nativeVoice', newSettings.nativeVoice);
  }

  void applyPreset(AccessibilityPreset preset) {
    AccessibilitySettings newSettings;
    switch (preset) {
      case AccessibilityPreset.dyslexia:
        newSettings = const AccessibilitySettings(
          preset: AccessibilityPreset.dyslexia,
          fontFamily: 'OpenDyslexic',
          lineSpacing: 1.5,
          darkMode: false, 
          ttsHighlighting: true,
          textScale: 1.0,
        );
        break;
      case AccessibilityPreset.visualImpairment:
        newSettings = const AccessibilitySettings(
          preset: AccessibilityPreset.visualImpairment,
          textScale: 2.0,
          highContrast: true,
          darkMode: true,
          voiceCommandPersistent: true,
        );
        break;
      case AccessibilityPreset.motorDifficulty:
        newSettings = const AccessibilitySettings(
          preset: AccessibilityPreset.motorDifficulty,
          touchTargetMargin: 16.0,
          defaultToStt: true,
          voiceCommandPersistent: true,
        );
        break;
      case AccessibilityPreset.standard:
      default:
        newSettings = const AccessibilitySettings(
          preset: AccessibilityPreset.standard,
        );
        break;
    }
    updateSettings(newSettings);
  }

  void setTextScale(double scale) => updateSettings(state.copyWith(textScale: scale));
  void setFontFamily(String family) => updateSettings(state.copyWith(fontFamily: family));
  void setLineSpacing(double spacing) => updateSettings(state.copyWith(lineSpacing: spacing));
  void toggleBoldText() => updateSettings(state.copyWith(boldText: !state.boldText));
  void toggleHighContrast() => updateSettings(state.copyWith(highContrast: !state.highContrast));
  void toggleDarkMode() => updateSettings(state.copyWith(darkMode: !state.darkMode));
  void toggleReadingRuler() => updateSettings(state.copyWith(readingRuler: !state.readingRuler));
  void setReadingSpeed(double speed) => updateSettings(state.copyWith(readingSpeed: speed > 3.0 ? 3.0 : speed));
  void setPreferredVoice(String voice) => updateSettings(state.copyWith(preferredVoice: voice));
  void toggleScreenReaderEnabled() => updateSettings(state.copyWith(screenReaderEnabled: !state.screenReaderEnabled));
  void setTtsEngine(String engine) => updateSettings(state.copyWith(ttsEngine: engine));

  void setPollySpeed(double val) => updateSettings(state.copyWith(pollySpeed: val > 3.0 ? 3.0 : val));
  void setPollyPitch(double val) => updateSettings(state.copyWith(pollyPitch: val));
  void setPollyVolume(double val) => updateSettings(state.copyWith(pollyVolume: val));
  void setPollyVoice(String val) => updateSettings(state.copyWith(pollyVoice: val));

  void setNativeSpeed(double val) => updateSettings(state.copyWith(nativeSpeed: val > 3.0 ? 3.0 : val));
  void setNativePitch(double val) => updateSettings(state.copyWith(nativePitch: val));
  void setNativeVolume(double val) => updateSettings(state.copyWith(nativeVolume: val));
  void setNativeVoice(String val) => updateSettings(state.copyWith(nativeVoice: val));
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final accessibilityProvider = NotifierProvider<AccessibilityNotifier, AccessibilitySettings>(() {
  return AccessibilityNotifier();
});
