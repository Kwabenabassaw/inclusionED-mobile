import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:opencampus_lms/core/utils/color_extension.dart';

/// Syntax to parse `==highlighted text::#HEXCOLOR==` into a custom Element.
class HighlightSyntax extends md.InlineSyntax {
  // Matches ==text::#HEX==
  HighlightSyntax() : super(r'==(.+?)::(#[0-9a-fA-F]{6})==');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final text = match[1]!;
    final colorHex = match[2]!;
    
    final element = md.Element.text('highlight', text);
    element.attributes['color'] = colorHex;
    
    parser.addNode(element);
    return true;
  }
}

/// Builder that takes the 'highlight' element and applies the parsed background color.
class HighlightBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final colorHex = element.attributes['color'] ?? '#FFFF00';
    final color = HexColor.fromHex(colorHex);

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border(bottom: BorderSide(color: color, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      child: Text(
        element.textContent,
        style: preferredStyle?.copyWith(
          color: Colors.black87,
        ),
      ),
    );
  }
}
