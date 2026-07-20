import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/providers/voice_overlay_controller.dart';
import 'package:opencampus_lms/core/providers/voice_providers.dart';
import 'package:opencampus_lms/core/services/voice/voice_command_state.dart';

/// Shows the [VoiceCommandOverlay] as a modal bottom sheet on top of the
/// current screen.
///
/// This is the ONLY entry-point. It must never be pushed as a named route.
///
/// [context] — the [BuildContext] of the screen that owns the FAB.
/// [ref]     — the [WidgetRef] from the parent ConsumerWidget.
Future<void> showVoiceCommandOverlay(
  BuildContext context,
  dynamic ref,
) async {
  final controller = ref.read(voiceOverlayControllerProvider.notifier);

  // Guard: do not open a second overlay while already active.
  if (controller.isActive) {
    debugPrint('[VoiceCmd] FAB tapped while already active — ignored.');
    return;
  }

  // Start the recording BEFORE showing the sheet so the mic is live when the
  // user sees the overlay (matches the Google Assistant feel).
  try {
    await controller.startListening(
      engine: ref.read(speechEngineProvider),
      parser: ref.read(fuzzyCommandInterpreterProvider),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not start microphone. Please check permissions.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    // barrierDismissible: true by default on ModalBottomSheet — tapping the
    // barrier cancels the voice session cleanly via the WillPopScope below.
    isDismissible: true,
    enableDrag: false, // Prevent accidental swipe-to-dismiss mid-sentence
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return PopScope(
        // When the barrier is tapped or back is pressed, cancel the session.
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) {
            ref.read(voiceOverlayControllerProvider.notifier).cancel();
          }
        },
        child: _VoiceCommandSheet(parentContext: context),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _VoiceCommandSheet extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const _VoiceCommandSheet({required this.parentContext});

  @override
  ConsumerState<_VoiceCommandSheet> createState() => _VoiceCommandSheetState();
}

class _VoiceCommandSheetState extends ConsumerState<_VoiceCommandSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(voiceOverlayControllerProvider);
    final controller = ref.read(voiceOverlayControllerProvider.notifier);

    // React to state changes
    ref.listen<VoiceOverlayData>(voiceOverlayControllerProvider,
        (previous, next) {
      if (previous?.state == next.state) return;

      // Announce state transitions for screen readers
      switch (next.state) {
        case VoiceCommandState.listening:
          SemanticsService.sendAnnouncement(
              View.of(context), 'Listening. Speak your command now.', TextDirection.ltr);
          _pulseController.repeat(reverse: true);
        case VoiceCommandState.processing:
          SemanticsService.sendAnnouncement(
              View.of(context), 'Processing your command.', TextDirection.ltr);
          _pulseController.stop();
        case VoiceCommandState.result:
          if (next.didFail) {
            SemanticsService.sendAnnouncement(
                View.of(context), 'Sorry, I didn\'t catch that.', TextDirection.ltr);
          } else {
            SemanticsService.sendAnnouncement(
                View.of(context), 'Command recognised. Executing.', TextDirection.ltr);
            // Auto-dismiss on success then execute action on the next frame
            // so the overlay is gone before navigation fires.
            _dismissAndExecute(next.resolvedIntent!);
          }
        case VoiceCommandState.idle:
          // Overlay should be closed — pop if still mounted.
          if (mounted) Navigator.of(context).maybePop();
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle indicator (visual only)
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24),

            // ── Main icon / animation ──────────────────────────────────────
            _buildStateIcon(context, data),
            SizedBox(height: 20),

            // ── Status label ───────────────────────────────────────────────
            _buildStatusLabel(context, data),
            SizedBox(height: 28),

            // ── Action buttons ─────────────────────────────────────────────
            _buildActionButtons(context, data, controller),

            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ─── Icon area ────────────────────────────────────────────────────────────

  Widget _buildStateIcon(BuildContext context, VoiceOverlayData data) {
    final color = Theme.of(context).colorScheme.primary;

    switch (data.state) {
      case VoiceCommandState.listening:
        return ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.mic, size: 52, color: color),
          ),
        );

      case VoiceCommandState.processing:
        return SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: color,
                ),
              ),
              Icon(Icons.mic_off, size: 36, color: color.withValues(alpha: 0.6)),
            ],
          ),
        );

      case VoiceCommandState.result:
        if (data.didFail) {
          return Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
            child: Icon(
              Icons.error_outline,
              size: 52,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          );
        }
        return Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withValues(alpha: 0.15),
          ),
          child: Icon(Icons.check_circle_outline, size: 52, color: Colors.green),
        );

      case VoiceCommandState.idle:
        return SizedBox(width: 96, height: 96);
    }
  }

  // ─── Status label ─────────────────────────────────────────────────────────

  Widget _buildStatusLabel(BuildContext context, VoiceOverlayData data) {
    final String label;
    final String? sublabel;

    switch (data.state) {
      case VoiceCommandState.listening:
        label = data.transcript.isNotEmpty ? data.transcript : 'Listening…';
        sublabel = data.transcript.isNotEmpty 
            ? 'Keep speaking, or tap the mic to stop.'
            : 'Speak your command, or tap the mic to stop early.';
      case VoiceCommandState.processing:
        label = 'Processing…';
        sublabel = 'Recognising your command.';
      case VoiceCommandState.result:
        if (data.didFail) {
          label = 'Sorry, I didn\'t catch that.';
          sublabel = 'Would you like to try again?';
        } else {
          label = 'Got it!';
          sublabel = null;
        }
      case VoiceCommandState.idle:
        label = '';
        sublabel = null;
    }

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
        if (sublabel != null) ...[
          SizedBox(height: 6),
          Text(
            sublabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ─── Action buttons ───────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext context,
    VoiceOverlayData data,
    VoiceOverlayController controller,
  ) {
    switch (data.state) {
      case VoiceCommandState.listening:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Manual stop — tapping while listening transitions to processing
            FilledButton.icon(
              onPressed: controller.stopRecording,
              icon: Icon(Icons.stop),
              label: Text('Stop'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                controller.cancel();
                Navigator.of(context).maybePop();
              },
              icon: Icon(Icons.close),
              label: Text('Cancel'),
            ),
          ],
        );

      case VoiceCommandState.processing:
        // Only a cancel button — processing cannot be manually fast-forwarded
        return OutlinedButton.icon(
          onPressed: () {
            controller.cancel();
            Navigator.of(context).maybePop();
          },
          icon: Icon(Icons.close),
          label: Text('Cancel'),
        );

      case VoiceCommandState.result:
        if (data.didFail) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Re-enter listening state
              FilledButton.icon(
                onPressed: () async {
                  // Reset state then start a fresh recording session
                  controller.resetToIdle();
                  await controller.startListening(
                    engine: ref.read(speechEngineProvider),
                    parser: ref.read(fuzzyCommandInterpreterProvider),
                  );
                },
                icon: Icon(Icons.mic),
                label: Text('Try Again'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  controller.cancel();
                  Navigator.of(context).maybePop();
                },
                icon: Icon(Icons.close),
                label: Text('Dismiss'),
              ),
            ],
          );
        }
        // Success — overlay will auto-dismiss via _dismissAndExecute
        return SizedBox.shrink();

      case VoiceCommandState.idle:
        return SizedBox.shrink();
    }
  }

  // ─── Dismiss + execute ────────────────────────────────────────────────────

  /// Pops the overlay FIRST, then fires the navigation action on the next
  /// frame so GoRouter pushes onto the correct underlying screen (not on top
  /// of the closing sheet).
  void _dismissAndExecute(Map<String, dynamic> intent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Pop the sheet
      Navigator.of(context).maybePop();

      // Execute action after the pop frame completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.parentContext.mounted) return;
        ref.read(voiceActionHandlerProvider).handleAction(
              intent,
              widget.parentContext,
              '',
            );
        ref.read(voiceOverlayControllerProvider.notifier).resetToIdle();
      });
    });
  }
}
