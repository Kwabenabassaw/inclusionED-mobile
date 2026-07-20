import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/core/enums/playback_state.dart';
import 'package:opencampus_lms/core/theme/app_dimensions.dart';
import 'package:opencampus_lms/features/modules/presentation/components/playback_controller.dart';
import 'package:opencampus_lms/features/modules/presentation/providers/readable_text_provider.dart';

class ReadingModeWrapper extends ConsumerWidget {
  final Widget child;

  const ReadingModeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final textToRead = ref.watch(currentReadableTextProvider);
    final theme = Theme.of(context);

    // If we're not speaking, just show the normal child widget
    if (playback.state != PlaybackState.speaking || textToRead.isEmpty) {
      return child;
    }

    // Otherwise, show the Reading Mode with Highlighting
    final textColor = theme.colorScheme.onSurface;
    final bgColor = theme.colorScheme.surface;

    // Use currentTextToSpeak from playback if available, fallback to the textToRead provider
    final text = playback.currentTextToSpeak.isNotEmpty
        ? playback.currentTextToSpeak
        : textToRead;

    Widget content;
    
    final baseStyle = theme.textTheme.bodyLarge?.copyWith(
      fontSize: (theme.textTheme.bodyLarge?.fontSize ?? 16) * 1.2,
      color: textColor,
      letterSpacing: 0.5,
    );

    if (playback.highlightEnd == 0 ||
        playback.highlightEnd > text.length ||
        playback.highlightStart >= playback.highlightEnd) {
      // If we don't have valid highlight bounds, just show the text without highlights
      content = Text(
        text,
        style: baseStyle,
      );
    } else {
      // Valid highlight bounds: slice the string and apply background color to the active word
      final beforeText = text.substring(0, playback.highlightStart);
      final highlightedWord = text.substring(
        playback.highlightStart,
        playback.highlightEnd,
      );
      final afterText = text.substring(playback.highlightEnd);

      final highlightStyle = baseStyle?.copyWith(
        backgroundColor: Colors.yellowAccent.shade100,
        color: Colors.black87,
        fontWeight: FontWeight.w900,
      );

      content = RichText(
        text: TextSpan(
          style: baseStyle,
          children: [
            TextSpan(text: beforeText),
            TextSpan(text: highlightedWord, style: highlightStyle),
            TextSpan(text: afterText),
          ],
        ),
      );
    }

    return Container(
      color: bgColor,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.marginPage),
        child: content,
      ),
    );
  }
}
