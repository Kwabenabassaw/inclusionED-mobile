import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/accessibility/unified_tts_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

/// Context provided to every IntentHandler during execution.
class IntentContext {
  final Map<String, dynamic> actionData;
  final BuildContext buildContext;
  final String screenText;
  final PlaybackController playbackController;
  final UnifiedTtsController fallbackTts;
  final AccessibilityNotifier accessibilityController;
  final Ref ref;

  IntentContext({
    required this.actionData,
    required this.buildContext,
    required this.screenText,
    required this.playbackController,
    required this.fallbackTts,
    required this.accessibilityController,
    required this.ref,
  });

  String get action => actionData['action'] as String;
  String? get target => actionData['target']?.toString();
}

/// Base interface for modular intent handlers.
abstract class IntentHandler {
  /// The list of action strings this handler can process.
  List<String> get supportedActions;

  /// Executes the intent. Returns true if handled successfully.
  Future<void> handle(IntentContext context);
}
