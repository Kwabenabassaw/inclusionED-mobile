import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';
import 'package:opencampus_lms/core/services/intent/handlers/intent_handler.dart';
import 'package:opencampus_lms/core/services/intent/handlers/navigation_intent_handler.dart';
import 'package:opencampus_lms/core/services/intent/handlers/accessibility_intent_handler.dart';
import 'package:opencampus_lms/core/services/intent/handlers/course_intent_handler.dart';
import 'package:opencampus_lms/core/services/intent/handlers/system_intent_handler.dart';

class VoiceActionHandler {
  final PlaybackController playbackController;
  final UnifiedTtsController fallbackTts;
  final AccessibilityNotifier accessibilityController;
  final Ref ref;

  final List<IntentHandler> _handlers = [
    NavigationIntentHandler(),
    AccessibilityIntentHandler(),
    CourseIntentHandler(),
    SystemIntentHandler(),
  ];

  VoiceActionHandler({
    required this.playbackController,
    required this.fallbackTts,
    required this.accessibilityController,
    required this.ref,
  });

  Future<void> handleAction(
    Map<String, dynamic>? actionData,
    BuildContext context,
    String screenText,
  ) async {
    if (actionData == null) {
      await fallbackTts.speak("Sorry, I didn't catch that.");
      return;
    }

    final intentContext = IntentContext(
      actionData: actionData,
      buildContext: context,
      screenText: screenText,
      playbackController: playbackController,
      fallbackTts: fallbackTts,
      accessibilityController: accessibilityController,
      ref: ref,
    );

    for (final handler in _handlers) {
      if (handler.supportedActions.contains(intentContext.action)) {
        await handler.handle(intentContext);
        return;
      }
    }

    await fallbackTts.speak("Sorry, I don't know how to do that yet.");
  }
}

