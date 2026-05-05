import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';

/// Plain text / log preview with monospace font and optional line numbers.
class TextPreview extends StatelessWidget {
  final String content;
  final bool showLineNumbers;
  final bool wordWrap;
  final double fontScale;

  const TextPreview({
    super.key,
    required this.content,
    this.showLineNumbers = true,
    this.wordWrap = true,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark
        ? ClaudeColors.darkTextPrimary
        : ClaudeColors.lightTextPrimary;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    final lines = content.split('\n');
    final fontSize = 13.0 * fontScale;

    final lineNumberWidth = showLineNumbers
        ? (lines.length.toString().length * 9.0 + 18)
        : 0.0;

    final textStyle = GoogleFonts.robotoMono(
      fontSize: fontSize,
      height: 1.55,
      color: fg,
    );

    Widget body = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: lines.length,
      itemBuilder: (context, i) {
        final line = lines[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLineNumbers)
                SizedBox(
                  width: lineNumberWidth,
                  child: Text(
                    (i + 1).toString(),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.robotoMono(
                      fontSize: fontSize,
                      color: secondary,
                      height: 1.55,
                    ),
                  ),
                ),
              if (showLineNumbers) const SizedBox(width: 12),
              Expanded(
                child: wordWrap
                    ? SelectableText(line.isEmpty ? ' ' : line, style: textStyle)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SelectableText(
                          line.isEmpty ? ' ' : line,
                          style: textStyle,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );

    return body;
  }
}
