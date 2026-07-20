import 'package:opencampus_lms/core/enums/playback_state.dart';
import 'package:opencampus_lms/core/services/intent/handlers/intent_handler.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';

class AccessibilityIntentHandler implements IntentHandler {
  @override
  List<String> get supportedActions => [
        'enableDarkMode',
        'disableDarkMode',
        'enableHighContrast',
        'disableHighContrast',
        'setSpeedFast',
        'setSpeedNormal',
        'setSpeedSlow',
        'readSlower',
        'readFaster',
        'increaseTextSize',
        'decreaseTextSize',
        'presetDyslexia',
        'presetVisual',
        'presetMotor',
        'presetStandard',
        'readPage',
        'pauseReading',
        'resumeReading',
        'stopSpeaking',
        'repeatThat',
      ];

  @override
  Future<void> handle(IntentContext context) async {
    final tts = context.fallbackTts;
    final playback = context.playbackController;
    final acc = context.accessibilityController;
    final accState = context.ref.read(accessibilityProvider);

    switch (context.action) {
      case 'enableDarkMode':
        if (!accState.darkMode) acc.toggleDarkMode();
        await tts.speak("Dark mode enabled.");
        break;

      case 'disableDarkMode':
        if (accState.darkMode) acc.toggleDarkMode();
        await tts.speak("Dark mode disabled.");
        break;

      case 'enableHighContrast':
        if (!accState.highContrast) acc.toggleHighContrast();
        await tts.speak("High contrast mode enabled.");
        break;

      case 'disableHighContrast':
        if (accState.highContrast) acc.toggleHighContrast();
        await tts.speak("High contrast mode disabled.");
        break;

      case 'setSpeedFast':
        await tts.setRate(1.5);
        acc.setPollySpeed(1.5);
        acc.setNativeSpeed(1.5);
        await tts.speak("Voice speed set to fast.");
        break;

      case 'setSpeedNormal':
        await tts.setRate(1.0);
        acc.setPollySpeed(1.0);
        acc.setNativeSpeed(1.0);
        await tts.speak("Voice speed set to normal.");
        break;

      case 'setSpeedSlow':
        await tts.setRate(0.5);
        acc.setPollySpeed(0.5);
        acc.setNativeSpeed(0.5);
        await tts.speak("Voice speed set to slow.");
        break;

      case 'readSlower':
        final currentSpeed1 = accState.nativeSpeed;
        final newSpeed1 = (currentSpeed1 - 0.1).clamp(0.1, 2.0);
        await tts.setRate(newSpeed1);
        acc.setNativeSpeed(newSpeed1);
        acc.setPollySpeed(newSpeed1);
        await tts.speak("Reading slower.");
        break;

      case 'readFaster':
        final currentSpeed2 = accState.nativeSpeed;
        final newSpeed2 = (currentSpeed2 + 0.1).clamp(0.1, 2.0);
        await tts.setRate(newSpeed2);
        acc.setNativeSpeed(newSpeed2);
        acc.setPollySpeed(newSpeed2);
        await tts.speak("Reading faster.");
        break;

      case 'increaseTextSize':
        final currentScale = accState.textScale;
        if (currentScale < 3.0) {
          acc.setTextScale(currentScale + 0.2);
          await tts.speak("Text size increased.");
        } else {
          await tts.speak("Text is already at maximum size.");
        }
        break;

      case 'decreaseTextSize':
        final currentScale = accState.textScale;
        if (currentScale > 0.8) {
          acc.setTextScale(currentScale - 0.2);
          await tts.speak("Text size decreased.");
        } else {
          await tts.speak("Text is already at minimum size.");
        }
        break;

      case 'presetDyslexia':
        acc.applyPreset(AccessibilityPreset.dyslexia);
        await tts.speak("Dyslexia mode enabled.");
        break;

      case 'presetVisual':
        acc.applyPreset(AccessibilityPreset.visualImpairment);
        await tts.speak("Visual impairment mode enabled.");
        break;

      case 'presetMotor':
        acc.applyPreset(AccessibilityPreset.motorDifficulty);
        await tts.speak("Motor difficulty mode enabled.");
        break;

      case 'presetStandard':
        acc.applyPreset(AccessibilityPreset.standard);
        await tts.speak("Standard settings restored.");
        break;

      case 'readPage':
      case 'resumeReading':
        if (context.screenText.isNotEmpty && !accState.screenReaderEnabled) {
          await playback.playOrResume(context.screenText);
        } else if (!accState.screenReaderEnabled) {
          await tts.speak("There is no text to read on this page.");
        }
        break;

      case 'pauseReading':
        if (context.ref.read(playbackControllerProvider).state == PlaybackState.speaking) {
          await playback.pause();
          await tts.speak("Reading paused.");
        } else {
          await tts.speak("Nothing is currently being read.");
        }
        break;

      case 'stopSpeaking':
        await playback.pause();
        await tts.stop();
        break;

      case 'repeatThat':
        await tts.speak("Repeating the last sentence is not yet fully supported.");
        break;
    }
  }
}
