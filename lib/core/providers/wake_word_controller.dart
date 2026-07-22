import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/providers/voice_providers.dart';
import 'package:opencampus_lms/core/services/voice/wake_word_service.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

import 'package:opencampus_lms/core/routing/app_router.dart';
import 'package:opencampus_lms/core/widgets/voice_command_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:opencampus_lms/core/providers/voice_overlay_controller.dart';
import 'package:opencampus_lms/core/services/voice/voice_command_state.dart';

final wakeWordControllerProvider = Provider<WakeWordController>((ref) {
  final controller = WakeWordController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class WakeWordController {
  final Ref ref;
  bool _isInitialized = false;

  WakeWordController(this.ref) {
    _init();
  }

  void _init() {
    // Watch accessibility settings specifically for the continuousListening flag
    ref.listen<bool>(
      accessibilityProvider.select((s) => s.continuousListening),
      (previous, isEnabled) {
        if (isEnabled) {
          _startListening();
        } else {
          _stopListening();
        }
      },
      fireImmediately: true, // Check initial state
    );

    // Watch for the voice overlay returning to idle state so we can restart
    // the wake word listener (it stops itself to prevent overlap).
    ref.listen<VoiceOverlayData>(
      voiceOverlayControllerProvider,
      (previous, current) {
        if (previous?.state != VoiceCommandState.idle &&
            current.state == VoiceCommandState.idle) {
          final isEnabled = ref.read(accessibilityProvider).continuousListening;
          if (isEnabled) {
            _startListening();
          }
        }
      },
    );
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      debugPrint("[WakeWordController] Microphone permission denied. Cannot start listening.");
      return;
    }

    final service = ref.read(wakeWordServiceProvider);
    
    if (!_isInitialized) {
      await service.initialize(
        onWakeWordDetected: _onWakeWordDetected,
      );
      _isInitialized = true;
    }
    
    await service.startListening();
    debugPrint("[WakeWordController] Started listening for wake word.");
  }

  Future<void> _stopListening() async {
    final service = ref.read(wakeWordServiceProvider);
    await service.stopListening();
    debugPrint("[WakeWordController] Stopped listening for wake word.");
  }

  void _onWakeWordDetected() {
    debugPrint("[WakeWordController] Wake word triggered! Opening overlay...");
    
    final overlayController = ref.read(voiceOverlayControllerProvider.notifier);
    
    // Check if it's already active to avoid double-triggering
    if (!overlayController.isActive) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        showVoiceCommandOverlay(context, ref);
      } else {
        debugPrint("[WakeWordController] Could not find current context to show overlay.");
      }
    }
  }

  void dispose() {
    _stopListening();
  }
}
