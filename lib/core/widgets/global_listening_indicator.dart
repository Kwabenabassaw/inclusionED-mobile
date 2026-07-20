import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/providers/voice_providers.dart';
import 'package:opencampus_lms/core/services/voice/voice_command_state.dart';

class GlobalListeningIndicator extends ConsumerStatefulWidget {
  final Widget child;

  const GlobalListeningIndicator({super.key, required this.child});

  @override
  ConsumerState<GlobalListeningIndicator> createState() => _GlobalListeningIndicatorState();
}

class _GlobalListeningIndicatorState extends ConsumerState<GlobalListeningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceOverlayControllerProvider).state;
    final isListening = voiceState == VoiceCommandState.listening;

    if (isListening && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isListening && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.animateTo(0, duration: const Duration(milliseconds: 300));
    }

    return Stack(
      children: [
        widget.child,
        
        // The glowing border overlay
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              if (!isListening && _pulseController.value == 0) {
                return const SizedBox.shrink();
              }
              
              final color = Theme.of(context).colorScheme.primary;
              
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color.withValues(alpha: _pulseAnimation.value * 0.8),
                    width: 6.0 + (_pulseAnimation.value * 4.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: _pulseAnimation.value * 0.3),
                      blurRadius: 20.0 + (_pulseAnimation.value * 10.0),
                      spreadRadius: 2.0 + (_pulseAnimation.value * 5.0),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
