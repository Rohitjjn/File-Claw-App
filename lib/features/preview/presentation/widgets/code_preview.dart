import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/claude_colors.dart';
import 'zoomable_view.dart';

/// Code preview with syntax highlighting via flutter_highlight.
///
/// Optional line numbers gutter is rendered to the left when enabled.
class CodePreview extends StatelessWidget {
  final String content;
  final String? language;
  final bool showLineNumbers;
  final double fontScale;

  const CodePreview({
    super.key,
    required this.content,
    this.language,
    this.showLineNumbers = true,
    this.fontScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? atomOneDarkTheme : atomOneLightTheme;
    final fontSize = 13.0 * fontScale;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    final lineCount = '\n'.allMatches(content).length + 1;
    final gutterWidth = showLineNumbers
        ? (lineCount.toString().length * 9.0 + 22)
        : 0.0;

    final lines = content.split('\n');

    return ZoomableView(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: lines.length,
        itemBuilder: (context, i) {
          final line = lines[i];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLineNumbers)
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4, top: 4),
                  child: SizedBox(
                    width: gutterWidth,
                    child: Text(
                      (i + 1).toString(),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.robotoMono(
                        fontSize: fontSize,
                        height: 1.55,
                        color: secondary,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SelectableRegion(
                    focusNode: FocusNode(),
                    selectionControls: materialTextSelectionControls,
                    child: HighlightView(
                      line.isEmpty ? ' ' : line,
                      language: language ?? 'plaintext',
                      theme: theme,
                      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
                      textStyle: GoogleFonts.robotoMono(
                        fontSize: fontSize,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
