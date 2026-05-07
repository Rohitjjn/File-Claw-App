import 'package:flutter/material.dart';

class MarkdownTextController extends TextEditingController {
  MarkdownTextController({super.text});

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final textStyle = style ?? const TextStyle();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syntaxStyle = isDark
        ? const TextStyle(color: Colors.blueAccent)
        : const TextStyle(color: Colors.blue);

    List<InlineSpan> spans = [];
    final textValue = text;

    // Regular expressions for bold, italic, headings
    final RegExp exp = RegExp(r'(\*\*[^*]+\*\*)|(\_[^_]+\_)|(\#[^\n]+)|(`[^`]+`)');
    int start = 0;

    for (final match in exp.allMatches(textValue)) {
      if (match.start > start) {
        spans.add(TextSpan(text: textValue.substring(start, match.start), style: textStyle));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText,
          style: textStyle.copyWith(fontWeight: FontWeight.bold, color: syntaxStyle.color),
        ));
      } else if (matchedText.startsWith('_') && matchedText.endsWith('_')) {
        spans.add(TextSpan(
          text: matchedText,
          style: textStyle.copyWith(fontStyle: FontStyle.italic, color: syntaxStyle.color),
        ));
      } else if (matchedText.startsWith('#')) {
        spans.add(TextSpan(
          text: matchedText,
          style: textStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        spans.add(TextSpan(
          text: matchedText,
          style: textStyle.copyWith(
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            fontFamily: 'monospace',
          ),
        ));
      } else {
        spans.add(TextSpan(text: matchedText, style: textStyle));
      }

      start = match.end;
    }

    if (start < textValue.length) {
      spans.add(TextSpan(text: textValue.substring(start), style: textStyle));
    }

    return TextSpan(style: style, children: spans);
  }
}
