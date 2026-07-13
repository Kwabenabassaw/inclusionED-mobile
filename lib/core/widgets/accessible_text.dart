import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opencampus_lms/features/accessibility/data/accessibility_provider.dart';

class AccessibleText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool semanticsLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.semanticsLabel = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibilitySettings = ref.watch(accessibilityProvider);

    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel ? text : null,
      style: (style ?? const TextStyle()).copyWith(
        fontFamily: accessibilitySettings.fontFamily != 'System' ? accessibilitySettings.fontFamily : null,
        height: accessibilitySettings.lineSpacing,
      ),
    );
  }
}
